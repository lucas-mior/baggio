model screen
    function calor_especifico
        input Real T(unit = "degC") "Temperatura";
        output Real c(unit = "kJ/(kg.degC)") "Calor específico";
    protected
        parameter Real A = 1.00269;
        parameter Real B = 3.4628e-5;
        parameter Real C = 8.94269e-8;
        parameter Real D = -3.63247e-11;
    algorithm
        c := A + B*T + C*T^2 + D*T^3;
    end calor_especifico;

    Modelica.Blocks.Interfaces.RealInput m_g(unit = "kg/s", start = 100)
    "Fluxo mássico dos gases"
    annotation( Placement(visible = true, transformation(origin = {-98, 68},
    extent = {{-42, -42}, {42, 42}}, rotation = 0), iconTransformation(origin =
    {-71, 3}, extent = {{-29, -29}, {29, 29}}, rotation = 0)));

    Modelica.Blocks.Interfaces.RealInput T_g(unit = "degC", start = 100)
    "Temperatura de entrada dos gases do screen"
    annotation( Placement(visible = true, transformation(origin = {-99, -3},
    extent = {{-43, -43}, {43, 43}}, rotation = 0), iconTransformation(origin =
    {-69, 69}, extent = {{-31, -31}, {31, 31}}, rotation = 0)));

    Modelica.Blocks.Interfaces.RealInput q_g(unit = "W", start = 100)
    "Fluxo de energia de entrada dos gases do screen"
    annotation( Placement(visible = true, transformation(origin = {-99, -73},
    extent = {{-45, -45}, {45, 45}}, rotation = 0), iconTransformation(origin =
    {-68, -66}, extent = {{-32, -32}, {32, 32}}, rotation = 0)));

    output Real q_ev(unit = "W", start = 1)
    "Fluxo de energia de saída do screen";
    output Real q_rad_ev(unit = "W", start = 1)
    "Fluxo de energia transferido por radiação no screen";
    output Real q_conv_ev(unit = "W", start = 1)
    "Fluxo de energia transferido por convecção no screen";
    output Real h_ev(unit = "kJ/kg", start = 1)
    "Entalpia dos gases na saída do screen";
    output Real cp_ev(unit = "kJ/(kg.degC)", start = 1)
    "Calor específico dos gases na saída do screen";
    output Real cp_ref(unit = "kJ/(kg.degC)", start = 1)
    "Calor específico de entrada dos gases do screen";
    output Real T_ev(unit = "degC", displayUnit="degC", start = 100)
    "Temperatura de saída dos gases do screen";
    output Real T_ev_med(unit = "degC", start = 100)
    "Temperatura média dos gases no screen";

    constant Real T_ref(unit = "degC") = 25
    "Temperatura ambiente";
    constant Real T_metal(unit = "degC") = 228
    "Temperatura média dos tubos de metal no screen";
    constant Real alpha_rad_ev(unit = "kW/K4") = 7.8998e-11
    "Constante de transferência de calor por radiação do screen";
    constant Real alpha_conv_ev(unit = "kW/K") = 0.8865
    "Constante de transferência de calor por convecção do screen";
equation
    q_g - q_ev - q_rad_ev - q_conv_ev = 0;

    cp_ref = calor_especifico(T_ref);
    cp_ev = calor_especifico(T_ev);

    q_rad_ev = alpha_rad_ev * (T_ev_med^4 - T_metal^4);
    q_conv_ev = alpha_conv_ev * (T_ev_med - T_metal);

    h_ev = cp_ev*T_ev - cp_ref*T_ref;
    q_ev = (m_g*h_ev)/10;

    T_ev_med = (T_g + T_ev)/2;

annotation(
    uses(Modelica(version = "4.0.0")));
end screen;