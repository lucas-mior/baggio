model Completo
    function calor_especifico_gas
        input Real T(unit="degC") "Temperatura";
        output Real c(unit="kJ/(kg.degC)") "Calor específico";
    protected
        parameter Real A = 1.00269;
        parameter Real B = 3.4628e-5;
        parameter Real C = 8.94269e-8;
        parameter Real D = -3.63247e-11;
    algorithm
        c := A + B*T + C*T^2 + D*T^3;
    end calor_especifico_gas;

    function calor_especifico_ar
        input Real T(unit="degC") "Temperatura";
        output Real c(unit="kJ/(kg.degC)") "Calor específico";
    algorithm
        c := 1.0356 - 0.00022*T + 4.1E-7*T^2;
    end calor_especifico_ar;

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
        input Real T_ar_out(unit="K", displayUnit="degC", start=400)
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
        Real T_ad(unit="K", displayUnit="degC", start=100)
        "Temperatura adiabática da chama";
        Real cp_g(unit="kJ/(kg.degC)")
        "Calor específico dos gases de saída da fornalha";
        Real cp_ad(unit="kJ/(kg.degC)")
        "Calor específico dos gases para temperatura adiabática";
        Real cp_ar_out(unit="kJ/(kg.degC)")
        "Calor específico do ar pré-aquecido";

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

        cp_ar_out = calor_especifico_ar(T_ar_out);
        cp_g = calor_especifico_gas(to_celsius(T_g));
        cp_ad = calor_especifico_gas(to_celsius(T_ad));

        h_ar_out = cp_ar_out*T_ar_out - cp_ref*(to_kelvin(T_ref));
        q_ar_out = m_ar_out*h_ar_out;

        q_rad_f = alpha_rad_f*(to_celsius(T_for)^4 - T_metal^4);
        q_conv_f = alpha_conv_f*(to_celsius(T_for) - T_metal);

        h_g = cp_g*T_g - cp_ref*(to_kelvin(T_ref));
        q_g = m_g*h_g;

        T_ad = (q_fuel + q_ar_out)/(m_g*cp_ad);
        T_for = (T_g + T_ad)/2;
    end Fornalha;

    model Evaporador
        input Real m_g(unit="kg/s", start=4.495)
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

        cp_ev = calor_especifico_gas(to_celsius(T_ev));
        cp_g = calor_especifico_gas(to_celsius(T_g));
        h_g = cp_g*T_g - cp_ref*to_kelvin(T_ref);
        
        T_ev_med = (T_g + T_ev)/2;
        q_rad_ev = alpha_rad_ev * (to_celsius(T_ev_med)^4 - T_metal^4);
        q_conv_ev = alpha_conv_ev * (to_celsius(T_ev_med) - T_metal);
        
        h_ev = cp_ev*T_ev - cp_ref*(to_kelvin(T_ref)); 
        q_ev = (m_g*h_ev);
    end Evaporador;

    model SuperAquecedor
        // lado dos gases
        input Real m_g(unit="kg/s", start=4.495)
        "fluxo mássico dos gases";
        input Real q_ev(unit="kW")
        "fluxo de energia de entrada do superquecedor";
        input Real T_ev(unit="K", displayUnit="degC", start=1000)
        "temperatura de entrada dos gases do superaquecedor";

        Real q_rad_s(unit="kW")
        "fluxo de de calor por radiação no superaquecedor";
        Real q_conv_s(unit="kW")
        "fluxo de de calor por convecção no superaquecedor";
        output Real q_s(unit="kW")
        "fluxo de energia de saída dos gases";

        Real cp_ev(unit="kJ/(kg.degC)")
        "Calor específico dos gases na entrada do superaquecedor";
        Real cp_s(unit="kJ/(kg.degC)")
        "Calor específico de saída dos gases do superaquecedor";

        Real h_ev(unit="kJ/kg")
        "Entalpia dos gases na entrada do evaporador";
        Real h_s(unit="kJ/kg")
        "Entalpia de saída dos gases do superaquecedor";

        input Real T_v1(unit="K", displayUnit="degC", start=500)
        "temperatura de entrada do vapor no superaquecedor";
        Real T_sv(unit="K", displayUnit="degC")
        "temperatura de saída do vapor do superaquecedor";
        Real T_metal_s(unit="K", displayUnit="degC")
        "temperatura média dos tubos de metal no superaquecedor";
        output Real T_s(unit="K", displayUnit="degC")
        "temperatura de saída dos gases do superaquecedor";
        Real T_s_med(unit="K", displayUnit="degC")
        "temperatura média dos gases no superaquecedor";

        constant Real alpha_rad_s(unit="kW/(degC4)") = 2.2e-10;
        constant Real alpha_conv_s(unit="kW/degC") = 2.25;

    equation
        q_ev - q_s - q_rad_s - q_conv_s = 0;

        cp_ev = calor_especifico_gas(to_celsius(T_ev));
        cp_s = calor_especifico_gas(to_celsius(T_s));

        h_ev = cp_ev*T_ev - cp_ref*to_kelvin(T_ref);
        q_ev = m_g*h_ev;

        q_rad_s = alpha_rad_s*(to_celsius(T_s)^4 - T_metal^4);
        q_conv_s = alpha_rad_s*(to_celsius(T_s) - T_metal);

        h_s = cp_s*T_s - cp_ref*T_ref;
        q_s = m_g*h_s;

        T_s_med = (T_ev + T_s)/2;
        T_metal_s = (T_ev + T_s)/6 + (T_v1 + T_sv)/3;

    // lado da água
    end SuperAquecedor;
    
    constant Real cp_ref(unit="kJ/(kg.degC)") = 1.007
    "Calor específico do ar ambiente";
    constant Real T_ref(unit="degC") = 25
    "Temperatura ambiente";
    constant Real T_metal(unit="degC") = 228
    "Temperatura média dos tubos de metal na fornalha";

    input Real T_ar_out(unit="K", displayUnit="degC", start=to_kelvin(200));

    model Tambor
        Real p(unit="bar", start=27)
        "Pressão";

        // rho, h e u são funções da pressão
        Real rho_v1(unit="kg/m3")
        "massa específica do vapor";
        Real rho_wt(unit="kg/m3")
        "massa específica dá água";
        Real h_v1(unit="kJ/kg")
        "entalpia do vapor";
        Real h_wt(unit="kJ/kg")
        "entalpia da água";
        Real u_wt(unit="kJ/kg")
        "energia interna da água";
        Real u_v1(unit="kJ/kg")
        "energia interna do vapor";

        constant Real h_f(unit="kJ/kg") = 441.841
        "entalpia da água de alimentação";
        Real Q(unit="kW")
        "fluxo de calor";

        Real m_f(unit="kg/s")
        "fluxo mássico de água que entra no tubulão";
        input Real m_v1(unit="kg/s", start=1.927)
        "fluxo mássico de água que saí do tubulão";

        Real V_v1(unit="m3", start=2)
        "volume de vapor no sistema";
        Real V_wt(unit="m3")
        "volume de água no sistema";
        constant Real V_t(unit="m3") = 14.4645
        "volume total";


        constant Real m_t(unit="kg") = 12324.333
        "massa total do metal";
        constant Real cp_metal(unit="kJ/(kg.degC)") = 0.550
        "calor específico do metal";
        // t_metal é funçao da pressão
        Real t_metal(unit="K")
        "temperatura do metal";

    equation
        p = 27 + 0.1*sin(time/100);
        V_v1 = 2+0.1*sin(time/100);
        V_t = V_v1 + V_wt;
        //der(V_wt) = -der(V_v1);

        // polinômios obtidos por regressão linear
        rho_v1  = 0.336208    + 0.483024*p - 0.000048*p^2 - 0.000008*p^3;
        rho_wt  = 932.309732  - 5.454961*p + 0.080024*p^2 - 0.000687*p^3;
        t_metal = 408.707924  + 5.521758*p - 0.102524*p^2 + 0.000922*p^3;
        h_v1    = 2731.845759 + 5.941585*p - 0.169762*p^2 + 0.001615*p^3;
        h_wt    = 578.773728 + 22.682809*p - 0.373929*p^2 + 0.003151*p^3;

        u_v1 = h_v1 - 1000*(p/rho_v1);
        u_wt = h_wt - 1000*(p/rho_wt);
        
        m_f - m_v1 = der(rho_v1*V_v1 + rho_wt*V_wt);

        Q + m_f*h_f - m_v1*h_v1 = der(rho_v1*u_v1*V_v1 + rho_wt*u_wt*V_wt + m_t*cp_metal*t_metal);

    end Tambor;

    Fornalha fornalha;
    Evaporador evaporador;
    SuperAquecedor superaquecedor;
equation
    fornalha.T_ar_out = T_ar_out;

    evaporador.m_g = fornalha.m_g;
    evaporador.T_g = fornalha.T_g;
    evaporador.q_g = fornalha.q_g;

    superaquecedor.m_g = evaporador.m_g; 
    superaquecedor.T_ev = evaporador.T_ev; 
    superaquecedor.q_ev = evaporador.q_ev; 
end Completo;
