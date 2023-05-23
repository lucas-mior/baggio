model fornalha2
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

    constant Real m_fuel(unit="kg/s") = 0.7942 "Fluxo de energia do combustível";
    constant Real m_ar(unit="kg/s") = 3.7008;
    output Real m_g(unit="kg/s", start=4.495);

    output Real q_fuel(unit="W", start=100)   "Fluxo de energia do combustível";
    output Real q_ar_out(unit="W", start=200) "Fluxo de energia do ar pré-aquecido";
    output Real q_rad_f(unit="W", start=300)  "Fluxo de energia transferido por radiação na fornalha";
    output Real q_conv_f(unit="W", start=400) "Fluxo de energia transferido por convecção na fornalha";
    output Real q_g(unit="W", start=500)     "Fluxo de energia de saída dos gases da fornalha";

    constant Real PCI(unit="kJ/kg") = 8223 "Poder calorífico inferior do combustível";

    input Real cp_ar_out(unit="kJ/(kg.K)", start=1) "Calor específico do ar pré-aquecido";
    input Real cp_g(unit="kJ/(kg.K)", start=1)      "Calor específico dos gases de saída da fornalha";
    Real cp_ad(unit="kJ/(kg.K)")     "Calor específico dos gases para temperatura adiabática";
    Real cp_ref(unit="kJ/(kg.K)")      "Calor específico do ar ambiente";

    input Real T_ar_out(unit="degC") "Temperatura do ar pré-aquecido";
    output Real T_g(unit="degC", start=1000) "Temperatura de saída dos gases da fornalha";

    output Real h_ar_out(unit="kJ/kg", start=10) "Entalpia do ar pré-aquecido";
    output Real h_g(unit="kJ/kg", start=10) "Entalpia dos gases de saída da fornalha";

    constant Real alpha_rad_f(unit="kW/(K.K.K.K)") = 3.5721e-10 "Constante de transferência de calor por radiação na fornalha";
    constant Real alpha_conv_f(unit="kW/K")  = 0.3758 "Constante de transferência de calor por convecção na fornalha";

    constant Real T_ref(unit="degC")   = 25  "Temperatura ambiente";
    constant Real T_metal(unit="degC") = 228 "Temperatura média dos tubos de metal na fornalha";

    Real T_for(unit="degC", start=1000) "Temperatura média dos gases na fornalha";
    Real T_ad(unit="degC", start=200)   "Temperatura adiabática da chama";
equation
    m_g = m_fuel + m_ar;
    q_fuel = m_fuel * PCI;
    
    cp_ad = calor_especifico(T_ad);
    cp_ref = calor_especifico(T_ref);
    
    h_ar_out = cp_ar_out * T_ar_out - cp_ref * T_metal;
    q_ar_out = m_ar * h_ar_out;

    q_rad_f = alpha_rad_f * (T_for^4 - T_metal^4);
    q_conv_f = alpha_conv_f * (T_for - T_metal);

    h_g = cp_g * T_g - cp_ref * T_metal;
    q_g = (m_g * h_g)/10;

    T_ad = (q_fuel + q_ar_out) / (m_g * cp_ad * 10);
    T_for = (T_g + T_ad) / 2;
end fornalha2;
