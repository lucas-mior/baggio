model fornalha
    function calor_especifico
        input Real T(unit = "degC") "Temperatura";
        output Real c "Calor específico";
    protected
        parameter Real A = 1.00269;
        parameter Real B = 3.4628e-5;
        parameter Real C = 8.94269e-8;
        parameter Real D = -3.63247e-11;
    algorithm
        c := A + B*T + C*T^2 + D*T^3;
    end calor_especifico;

    Modelica.Blocks.Interfaces.RealInput T_ar_out(unit = "degC", start = 100)
    "Temperatura do ar pré-aquecido"
    annotation(Placement(visible = true, transformation(origin = {-100, 0},
    extent = {{-82, -82}, {82, 82}}, rotation = 0), iconTransformation(origin =
    {-66, 0}, extent = {{-34, -34}, {34, 34}}, rotation = 0)));

    constant Real m_fuel(unit = "kg/s") = 0.7942
    "Fluxo de energia do combustível";

    constant Real m_ar_out(unit = "kg/s") = 3.7008
    "Fluxo mássico de ar pré-aquecido";
    constant Real alpha_rad_f(unit = "kW/(K4)") = 3.5721e-10
    "Constante de transferência de calor por radiação na fornalha";
    constant Real alpha_conv_f(unit = "kW/K") = 0.3758
    "Constante de transferência de calor por convecção na fornalha";
    constant Real T_ref(unit = "degC") = 25
    "Temperatura ambiente";
    constant Real T_metal(unit = "degC") = 228
    "Temperatura média dos tubos de metal na fornalha";
    constant Real PCI(unit = "kJ/kg") = 8223
    "Poder calorífico inferior do combustível";

    Real T_for(unit = "degC", start = 1000)
    "Temperatura média dos gases na fornalha";
    Real T_ad(unit = "degC", start = 200)
    "Temperatura adiabática da chama";
    Real cp_ar_out(unit = "kJ/(kg.degC)", start = 1)
    "Calor específico do ar pré-aquecido";
    Real cp_g(unit = "kJ/(kg.degC)", start = 1)
    "Calor específico dos gases de saída da fornalha";
    Real cp_ad(unit = "kJ/(kg.degC)", start = 1)
    "Calor específico dos gases para temperatura adiabática";
    Real cp_ref(unit = "kJ/(kg.degC)", start = 1)
    "Calor específico do ar ambiente";

    output Real q_fuel(unit = "W", start = 100)
    "Fluxo de energia do combustível";
    output Real q_ar_out(unit = "W", start = 200)
    "Fluxo de energia do ar pré-aquecido";
    output Real q_rad_f(unit = "W", start = 300)
    "Fluxo de energia transferido por radiação na fornalha";
    output Real q_conv_f(unit = "W", start = 400)
    "Fluxo de energia transferido por convecção na fornalha";
    output Real h_ar_out(unit = "kJ/kg", start = 10)
    "Entalpia do ar pré-aquecido";
    output Real h_g(unit = "kJ/kg", start = 10)
    "Entalpia dos gases de saída da fornalha";

    Modelica.Blocks.Interfaces.RealOutput T_g(unit = "degC", start = 1000)
    "Temperatura de saída dos gases da fornalha"
    annotation(Placement(visible = true, transformation(origin = {100, 64},
    extent = {{-70, -70}, {70, 70}}, rotation = 0), iconTransformation(origin =
    {70, 70}, extent = {{-30, -30}, {30, 30}}, rotation = 0)));
    Modelica.Blocks.Interfaces.RealOutput q_g(unit = "W", start = 500)
    "Fluxo de energia de saída dos gases da fornalha" 
    annotation(Placement(visible = true, transformation(origin = {97, -67},
    extent = {{-65, -65}, {65, 65}}, rotation = 0), iconTransformation(origin =
    {70, -70}, extent = {{-30, -30}, {30, 30}}, rotation = 0)));
    output Modelica.Blocks.Interfaces.RealOutput m_g(unit = "kg/s", start = 4.495)
    "Fluxo mássico dos gases" annotation(
    Placement(visible = true, transformation(origin = {0, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {70, 0}, extent = {{-30, -30}, {30, 30}}, rotation = 0)));
equation
    q_fuel + q_ar_out - q_g - q_rad_f - q_conv_f = 0;
    m_g = m_fuel + m_ar_out;
    q_fuel = m_fuel*PCI;

    cp_ar_out = calor_especifico(T_ar_out);
    cp_ref = calor_especifico(T_ref);
    cp_g = calor_especifico(T_g);
    cp_ad = calor_especifico(T_ad);

    h_ar_out = cp_ar_out*T_ar_out - cp_ref*T_ref;
    q_ar_out = m_ar_out*h_ar_out;

    q_rad_f = alpha_rad_f*(T_for^4 - T_metal^4);
    q_conv_f = alpha_conv_f*(T_for - T_metal);

    h_g = cp_g*T_g - cp_ref*T_metal;
    q_g = (m_g*h_g)/10;

    T_ad = (q_fuel + q_ar_out)/(m_g*cp_ad*10);
    T_for = (T_g + T_ad)/2;
annotation(
    uses(Modelica(version = "4.0.0")));
end fornalha;