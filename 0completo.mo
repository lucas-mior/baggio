model Completo
    function calor_especifico
        input Real T(unit="degC") "Temperatura";
        output Real c(unit="kJ/(kg.degC)") "Calor específico";
    protected
        parameter Real A = 1.00269;
        parameter Real B = 3.4628e-5;
        parameter Real C = 8.94269e-8;
        parameter Real D = -3.63247e-11;
    algorithm
        c := A + B*T + C*T^2 + D*T^3;
    end calor_especifico;

    function to_celsius
        input Real Tkelvin(unit="K") "Temperatura em Kelvin";
        output Real Tcelsius(unit="degC") "Temperatura em graus celsius";
    algorithm
        Tcelsius := Tkelvin - 273.15;
    end to_celsius;

    function to_kelvin
        input Real Tcelsius(unit="degC") "Temperatura em graus celsius";
        output Real Tkelvin(unit="K") "Temperatura em Kelvin";
    algorithm
        Tkelvin := Tcelsius + 273.15;
    end to_kelvin;

    model Fornalha
        input Real T_ar_out(unit="K", displayUnit="degC")
        "Temperatura do ar pré-aquecido";
        constant Real m_fuel(unit="kg/s") = 0.7942
        "Fluxo mássico de combustível";
        constant Real m_ar_out(unit="kg/s") = 3.7008
        "Fluxo mássico de ar pré-aquecido";
        constant Real alpha_rad_f(unit="kW/(degC4)") = 3.5721e-10
        "Constante de transferência de calor por radiação na fornalha";
        constant Real alpha_conv_f(unit="kW/degC") = 0.3758
        "Constante de transferência de calor por convecção na fornalha";
        constant Real PCI(unit="kJ/kg") = 8223
        "Poder calorífico inferior do combustível";

        Real T_for(unit="K", displayUnit="degC")
        "Temperatura média dos gases na fornalha";
        Real T_ad(unit="K", displayUnit="degC")
        "Temperatura adiabática da chama";
        Real cp_ar_out(unit="kJ/(kg.degC)")
        "Calor específico do ar pré-aquecido";
        Real cp_g(unit="kJ/(kg.degC)")
        "Calor específico dos gases de saída da fornalha";
        Real cp_ad(unit="kJ/(kg.degC)")
        "Calor específico dos gases para temperatura adiabática";
        Real cp_ref(unit="kJ/(kg.degC)")
        "Calor específico do ar ambiente";

        output Real q_fuel(unit="kW")
        "Fluxo de energia do combustível";
        output Real q_ar_out(unit="kW")
        "Fluxo de energia do ar pré-aquecido";
        output Real q_rad_f(unit="kW")
        "Fluxo de energia transferido por radiação na fornalha";
        output Real q_conv_f(unit="kW")
        "Fluxo de energia transferido por convecção na fornalha";
        output Real h_ar_out(unit="kJ/kg")
        "Entalpia do ar pré-aquecido";
        output Real h_g(unit="kJ/kg")
        "Entalpia dos gases de saída da fornalha";

        output Real T_g(unit="K", displayUnit="degC")
        "Temperatura de saída dos gases da fornalha";
        output Real q_g(unit="kW")
        "Fluxo de energia de saída dos gases da fornalha";
        output Real m_g(unit="kg/s")
        "Fluxo mássico dos gases";
    equation
        q_fuel + q_ar_out - q_g - q_rad_f - q_conv_f = 0;
        m_g = m_fuel + m_ar_out;
        
        q_fuel = m_fuel*PCI;

        cp_ar_out = calor_especifico(to_celsius(T_ar_out));
        cp_ref = calor_especifico(T_ref);
        cp_g = calor_especifico(to_celsius(T_g));
        cp_ad = calor_especifico(to_celsius(T_ad));

        h_ar_out = cp_ar_out*T_ar_out - cp_ref*(to_kelvin(T_ref));
        q_ar_out = m_ar_out*h_ar_out;

        q_rad_f = alpha_rad_f*(to_celsius(T_for)^4 - T_metal^4);
        q_conv_f = alpha_conv_f*(T_for - to_kelvin(T_metal));

        h_g = cp_g*T_g - cp_ref*(to_kelvin(T_ref));
        q_g = m_g*h_g;

        T_ad = (q_fuel + q_ar_out)/(m_g*cp_ad);
        T_for = (T_g + T_ad)/2;
    end Fornalha;

    model Evaporador
        input Real m_g(unit="kg/s", start=)
        "Fluxo mássico dos gases";
        input Real T_g(unit="K", displayUnit="degC")
        "Temperatura de entrada dos gases do evaporador";
        input Real q_g(unit="kW")
        "Fluxo de energia de entrada dos gases do evaporador";

        output Real q_ev(unit="kW")
        "Fluxo de energia de saída do evaporador";
        output Real q_rad_ev(unit="kW")
        "Fluxo de energia transferido por radiação no evaporador";
        output Real q_conv_ev(unit="kW")
        "Fluxo de energia transferido por convecção no evaporador";
        output Real h_ev(unit="kJ/kg")
        "Entalpia dos gases na saída do evaporador";
        output Real h_g(unit="kJ/kg")
        "Entalpia dos gases na saída da fornalha";
        output Real cp_ev(unit="kJ/(kg.degC)")
        "Calor específico dos gases na saída do evaporador";
        output Real cp_ref(unit="kJ/(kg.degC)")
        "Calor específico de entrada dos gases do evaporador";
        output Real cp_g(unit="kJ/(kg.degC)")
        "Calor específico dos gases na saída da fornalha";
        output Real T_ev(unit="K", displayUnit="degC", start=500)
        "Temperatura de saída dos gases do evaporador";
        output Real T_ev_med(unit="K", displayUnit="degC")
        "Temperatura média dos gases no evaporador";

        constant Real alpha_rad_ev(unit="kW/K4") = 7.8998e-11
        "Constante de transferência de calor por radiação do evaporador";
        constant Real alpha_conv_ev(unit="kW/K") = 0.8865
        "Constante de transferência de calor por convecção do evaporador";
    equation
        q_g - q_ev - q_rad_ev - q_conv_ev = 0;

        cp_ref = calor_especifico(T_ref);
        cp_ev = calor_especifico(to_celsius(T_ev));

        cp_g = calor_especifico(to_celsius(T_g));
        h_g = cp_g*T_g - cp_ref*to_kelvin(T_ref);
        
        T_ev_med = (T_g + T_ev)/2;
        q_rad_ev = alpha_rad_ev * (to_celsius(T_ev_med)^4 - T_metal^4);
        q_conv_ev = alpha_conv_ev * (T_ev_med - to_kelvin(T_metal));
        
        h_ev = cp_ev*T_ev - cp_ref*(to_kelvin(T_ref)); 
        q_ev = (m_g*h_ev);
    end Evaporador;

    model SuperAquecedor
        // lado dos gases
        input Real m_g(unit="kg/s", start=4.495)
        "fluxo mássico dos gases";
        input Real q_ev(unit="kW")
        "fluxo de energia de entrada do superquecedor";
        input Real T_ev(unit="K", displayUnit="degC")
        "temperatura de entrada dos gases do superaquecedor";

        Real q_rad_s(unit="kW");
        Real q_conv_s(unit="kW");

        Real cp_ev(unit="kJ/(kg.degC)")
        "Calor específico dos gases na entrada do superaquecedor";
        Real cp_ref(unit="kJ/(kg.degC)")
        "Calor específico do ar na temperatura ambiente";
        Real cp_s(unit="kJ/(kg.degC)")
        "Calor específico de saída dos gases do superaquecedor";

        Real h_ev(unit="kJ/kg")
        "Entalpia dos gases na entrada do evaporador";
        Real h_s(unit="kJ/kg")
        "Entalpia de saída dos gases do superaquecedor";

        Real T_s(unit="K", displayUnit="degC");
        Real T_sv(unit="K", displayUnit="degC");
        Real T_s_med(unit="K", displayUnit="degC");
        input Real T_v1(unit="K", displayUnit="degC", start=500);
        Real T_metal_s(unit="K", displayUnit="degC");

        output Real q_s(unit="kW");

        constant Real alpha_rad_s(unit="kW/(degC4)") = 2.2e-10;
        constant Real alpha_conv_s(unit="kW/degC") = 2.25;

    equation
        q_ev - q_s - q_rad_s - q_conv_s = 0;

        cp_ref = calor_especifico(T_ref);
        cp_ev = calor_especifico(to_celsius(T_ev));
        cp_s = calor_especifico(to_celsius(T_s));

        h_ev = cp_ev*T_ev - cp_ref*to_kelvin(T_ref);
        q_ev = m_g*h_ev;

        q_rad_s = alpha_rad_s*(to_celsius(T_s)^4 - T_metal^4);
        q_conv_s = alpha_rad_s*(T_s - to_kelvin(T_metal));

        h_s = cp_s*T_s - cp_ref*T_ref;
        q_s = m_g*h_s;

        T_s_med = (T_ev + T_s)/2;
        T_metal_s = (T_ev + T_s)/6 + (T_v1 + T_sv)/3;

    // lado da água
    end SuperAquecedor;
    
    constant Real T_ref(unit="degC") = 25
    "Temperatura ambiente";
    constant Real T_metal(unit="degC") = 228
    "Temperatura média dos tubos de metal na fornalha";

    input Real T_ar_out(unit="K", displayUnit="degC", start=to_kelvin(200));

    Fornalha fornalha;
    Evaporador evaporador;
    SuperAquecedor superaquecedor;
equation
    fornalha.T_ar_out = T_ar_out;

    evaporador.m_g = fornalha.m_g;
    evaporador.T_g = fornalha.T_g;
    evaporador.q_g = fornalha.q_g;

    superaquecedor.m_g = fornalha.m_g; 
end Completo;
