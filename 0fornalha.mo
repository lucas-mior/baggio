model fornalha
    function calor_especifico
        input Real T(unit="degC") "Temperatura";
        output Real c "Calor específico";
    protected
        parameter Real A = 1.00269;
        parameter Real B = 3.4628e-5;
        parameter Real C = 8.94269e-8;
        parameter Real D = -3.63247e-11;
    algorithm
        c := A + B*T + C*T^2 + D*T^3;
    end calor_especifico;

    constant Real m_fuel(unit="kg/s") = 0.7942
    "Fluxo mássico de combustível";
    constant Real m_ar_out(unit="kg/s") = 3.7008
    "Fluxo mássico de ar pré-aquecido";
    constant Real alpha_rad_f(unit="kW/(K4)") = 3.5721e-10
    "Constante de transferência de calor por radiação na fornalha";
    constant Real alpha_conv_f(unit="kW/K") = 0.3758
    "Constante de transferência de calor por convecção na fornalha";
    constant Real T_ref(unit="degC") = 25
    "Temperatura ambiente";
    constant Real T_metal(unit="degC") = 228
    "Temperatura média dos tubos de metal na fornalha";
    constant Real PCI(unit="kJ/kg") = 8223
    "Poder calorífico inferior do combustível";

    Real T_for(unit="K")
    "Temperatura média dos gases na fornalha";
    Real T_ad(unit="K")
    "Temperatura adiabática da chama";
    Real cp_ar_out(unit="kJ/(kg.degC)")
    "Calor específico do ar pré-aquecido";
    Real cp_g(unit="kJ/(kg.degC)")
    "Calor específico dos gases de saída da fornalha";
    Real cp_ad(unit="kJ/(kg.degC)")
    "Calor específico dos gases para temperatura adiabática";
    Real cp_ref(unit="kJ/(kg.degC)")
    "Calor específico do ar ambiente";

    output Real q_fuel(unit="W")
    "Fluxo de energia do combustível";
    output Real q_ar_out(unit="W")
    "Fluxo de energia do ar pré-aquecido";
    output Real q_rad_f(unit="W")
    "Fluxo de energia transferido por radiação na fornalha";
    output Real q_conv_f(unit="W")
    "Fluxo de energia transferido por convecção na fornalha";
    output Real h_ar_out(unit="kJ/kg")
    "Entalpia do ar pré-aquecido";
    output Real h_g(unit="kJ/kg")
    "Entalpia dos gases de saída da fornalha";

    Modelica.Blocks.Interfaces.RealInput T_ar_out(unit="K", start=200)
    "Temperatura do ar pré-aquecido"
    annotation(Placement(visible = true, transformation(origin = {-100, 0}, extent = {{-82, -82}, {82, 82}}, rotation = 0), iconTransformation(origin = {-66, 0}, extent = {{-34, -34}, {34, 34}}, rotation = 0)));
    Modelica.Blocks.Interfaces.RealOutput T_g(unit="K")
    "Temperatura de saída dos gases da fornalha"
    annotation(Placement(visible = true, transformation(origin = {100, 64}, extent = {{-70, -70}, {70, 70}}, rotation = 0), iconTransformation(origin = {70, 70}, extent = {{-30, -30}, {30, 30}}, rotation = 0)));
    Modelica.Blocks.Interfaces.RealOutput q_g(unit="W")
    "Fluxo de energia de saída dos gases da fornalha" 
    annotation(Placement(visible = true, transformation(origin = {97, -67}, extent = {{-65, -65}, {65, 65}}, rotation = 0), iconTransformation(origin = {70, -70}, extent = {{-30, -30}, {30, 30}}, rotation = 0)));
    output Modelica.Blocks.Interfaces.RealOutput m_g(unit="kg/s")
    "Fluxo mássico dos gases"
    annotation( Placement(visible = true, transformation(origin = {97, -1}, extent = {{-63, -63}, {63, 63}}, rotation = 0), iconTransformation(origin = {70, 0}, extent = {{-30, -30}, {30, 30}}, rotation = 0)));
equation
    q_fuel + q_ar_out - q_g - q_rad_f - q_conv_f = 0;
    m_g = m_fuel + m_ar_out;
    q_fuel = m_fuel*PCI;

    cp_ar_out = calor_especifico(T_ar_out-273);
    cp_ref = calor_especifico(T_ref);
    cp_g = calor_especifico(T_g-273);
    cp_ad = calor_especifico(T_ad-273);

    h_ar_out = cp_ar_out*T_ar_out - cp_ref*(T_ref+273);
    q_ar_out = m_ar_out*h_ar_out;

    q_rad_f = alpha_rad_f*(T_for^4 - (T_metal+273)^4);
    q_conv_f = alpha_conv_f*(T_for - (T_metal+273));

    h_g = cp_g*T_g - cp_ref*(T_metal+273);
    q_g = (m_g*h_g)/10;

    T_ad = (q_fuel + q_ar_out)/(m_g*cp_ad*10);
    T_for = (T_g + T_ad)/2;
annotation(
    uses(Modelica(version = "4.0.0")));
end fornalha;