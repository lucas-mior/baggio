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

    function calor_especifico_agua
        input Real T(unit="degC") "Temperatura";
        output Real c(unit="kJ/(kg.degC)") "Calor específico";
    algorithm
        c := 4.18;
    end calor_especifico_agua;

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
        "temperatura do ar pré-aquecido";
        input Real q_ar_out(unit="kW", start=50)
        "fluxo de energia do ar pré-aquecido";

        Real T_for(unit="K", displayUnit="degC")
        "temperatura média dos gases da fornalha";
        Real T_ad(unit="K", displayUnit="degC", start=100)
        "temperatura adiabática da chama";
        Real T_metal(unit="K", displayUnit="degC")
        "temperatura média dos tubos de metal da fornalha";

        Real q_fuel(unit="kW")
        "fluxo de energia do combustível";
        Real q_rad_f(unit="kW")
        "fluxo de calor por radiação da fornalha";
        Real q_conv_f(unit="kW")
        "fluxo de calor por convecção da fornalha";

        Real cp_g(unit="kJ/(kg.degC)")
        "calor específico dos gases de saída da fornalha";
        Real cp_ad(unit="kJ/(kg.degC)")
        "calor específico dos gases para temperatura adiabática";
        Real cp_ar_out(unit="kJ/(kg.degC)")
        "calor específico do ar pré-aquecido";
        Real h_g(unit="kJ/kg")
        "entalpia dos gases de saída da fornalha";

        output Real T_g(unit="K", displayUnit="degC")
        "temperatura dos gases de saída da fornalha";
        output Real q_g(unit="kW")
        "fluxo de energia dos gases de saída da fornalha";
        output Real m_g(unit="kg/s")
        "fluxo mássico dos gases";
    equation
        m_g - m_fuel - m_ar = 0;
        q_fuel + q_ar_out - q_g - q_rad_f - q_conv_f = 0;
        
        q_fuel = m_fuel*PCI;

        cp_ar_out = calor_especifico_ar(T_ar_out);
        cp_g = calor_especifico_gas(to_celsius(T_g));
        cp_ad = calor_especifico_gas(to_celsius(T_ad));

        T_metal = to_kelvin(T_sat);
        q_rad_f = alpha_rad_f*(to_celsius(T_for)^4 - T_metal^4);
        q_conv_f = alpha_conv_f*(to_celsius(T_for) - T_metal);

        h_g = cp_g*T_g - cp_ref*(to_kelvin(T_ref));
        q_g = m_g*h_g;

        T_ad = (q_fuel + q_ar_out)/(m_g*cp_ad);
        T_for = (T_g + T_ad)/2;
    end Fornalha;

    model Evaporador
        input Real m_g(unit="kg/s", start=4.495)
        "fluxo mássico dos gases";
        input Real T_g(unit="K", displayUnit="degC", start=800)
        "temperatura dos gases de entrada do evaporador";
        input Real q_g(unit="kW", start=1000)
        "fluxo de energia dos gases de entrada do evaporador";

        output Real q_ev(unit="kW")
        "fluxo de energia de saída do evaporador";

        Real q_rad_ev(unit="kW")
        "fluxo de calor por radiação do evaporador";
        Real q_conv_ev(unit="kW")
        "fluxo de calor por convecção do evaporador";

        Real cp_ev(unit="kJ/(kg.degC)")
        "calor específico dos gases de saída do evaporador";
        Real cp_g(unit="kJ/(kg.degC)")
        "output calor específico dos gases de saída da fornalha";
        Real h_ev(unit="kJ/kg")
        "entalpia dos gases de saída do evaporador";
        Real h_g(unit="kJ/kg")
        "entalpia dos gases de saída da fornalha";

        Real T_metal(unit="K", displayUnit="degC")
        "temperatura média dos tubos de metal do evaporador";
        output Real T_ev(unit="K", displayUnit="degC", start=500)
        "temperatura de saída dos gases do evaporador";
        Real T_ev_med(unit="K", displayUnit="degC")
        "temperatura média dos gases do evaporador";

    equation
        q_g - q_ev - q_rad_ev - q_conv_ev = 0;

        cp_g = calor_especifico_gas(to_celsius(T_g));
        cp_ev = calor_especifico_gas(to_celsius(T_ev));
        h_g = cp_g*T_g - cp_ref*to_kelvin(T_ref);
        
        T_metal = to_kelvin(T_sat);
        q_rad_ev = alpha_rad_ev * (to_celsius(T_ev_med)^4 - T_metal^4);
        q_conv_ev = alpha_conv_ev * (to_celsius(T_ev_med) - T_metal);
        
        h_ev = cp_ev*T_ev - cp_ref*(to_kelvin(T_ref)); 
        q_ev = (m_g*h_ev);

        T_ev_med = (T_g + T_ev)/2;
    end Evaporador;

    model SuperAquecedorGases
        input Real m_g(unit="kg/s", start=4.495)
        "fluxo mássico dos gases";
        input Real q_ev(unit="kW", start=500)
        "fluxo de energia de entrada do superquecedor";
        input Real T_ev(unit="K", displayUnit="degC", start=800)
        "temperatura dos gases de entrada do superaquecedor";
        input Real T_v1(unit="K", displayUnit="degC", start=500)
        "temperatura do vapor de entrada do superaquecedor";

        output Real q_rad_s(unit="kW")
        "fluxo de calor por radiação do superaquecedor";
        output Real q_conv_s(unit="kW")
        "fluxo de calor por convecção do superaquecedor";
        output Real q_s(unit="kW")
        "fluxo de energia de saída dos gases do superaquecedor";

        output Real T_s(unit="K", displayUnit="degC")
        "temperatura dos gases de saída do superaquecedor";

        Real cp_s(unit="kJ/(kg.degC)")
        "calor específico dos gases de saída do superaquecedor";
        Real h_s(unit="kJ/kg")
        "entalpia dos gases de saída do superaquecedor";

        input Real T_sv(unit="K", displayUnit="degC", start=100)
        "temperatura do vapor de saída do superaquecedor";
        Real T_metal_s(unit="K", displayUnit="degC")
        "temperatura dos tubos de metal média do superaquecedor";
        Real T_s_med(unit="K", displayUnit="degC")
        "temperatura dos gases média do superaquecedor";

    equation
        q_ev - q_s - q_rad_s - q_conv_s = 0;

        cp_s = calor_especifico_gas(to_celsius(T_s));

        q_rad_s = alpha_rad_s*(to_celsius(T_s_med)^4 - T_metal_s^4);
        q_conv_s = alpha_rad_s*(to_celsius(T_s_med) - T_metal_s);

        h_s = cp_s*T_s - cp_ref*to_kelvin(T_ref);
        q_s = m_g*h_s;

        T_s_med = (T_ev + T_s)/2;
        T_metal_s = (T_ev + T_s)/6 + (T_v1 + T_sv)/3;

    end SuperAquecedorGases;

    model SuperAquecedorVapor
        // input Real m_v1(unit="kg/s", start=3)
        // "fluxo mássico de vapor de entrada do superaquecedor";
        output Real m_sv(unit="kg/s")
        "fluxo mássico de vapor de saída do superaquecedor";

        Real q_v1(unit="kW")
        "fluxo de energia de entrada do superaquecedor";
        output Real q_sv(unit="kW")
        "fluxo de energia de saída dos gases do superaquecedor";
        Real q_conv_s_v1(unit="kW")
        "fluxo de calor por convecção para o vapor do superaquecedor";

        input Real q_rad_s(unit="kW", start=500)
        "fluxo de calor por radiação do superaquecedor";
        input Real q_conv_s(unit="kW", start=500)
        "fluxo de calor por convecção do superaquecedor";

        Real cp_v1(unit="kJ/(kg.degC)")
        "calor específico do vapor de entrada do superaquecedor";
        Real cp_sv(unit="kJ/(kg.degC)")
        "calor específico do vapor de saída do superaquecedor";
        Real h_v1(unit="kJ/kg")
        "entalpia do vapor de entrada do superaquecedor";
        Real h_sv(unit="kJ/kg")
        "entalpia do vapor de saída do superaquecedor";

        input Real T_v1(unit="K", displayUnit="degC", start=400)
        "temperatura do vapor de entrada do superaquecedor";
        output Real T_sv(unit="K", displayUnit="degC")
        "temperatura do vapor de saída do superaquecedor";


    equation
        m_v1 - m_sv = 0;
        q_v1 - q_sv + q_conv_s_v1 = 0;

        cp_v1 = calor_especifico_agua(T_v1);
        cp_sv = calor_especifico_agua(T_sv);

        h_v1 = cp_v1*T_v1 - cp_ref*to_kelvin(T_ref);
        q_v1 = m_v1*h_v1;

        q_conv_s_v1 = q_rad_s + q_conv_s;

        h_sv = cp_sv*T_sv - cp_ref*T_ref;
        q_sv = m_sv*h_sv;

    end SuperAquecedorVapor;

    model PassagemTubos
        input Real m_g(unit="kg/s", start=4.495)
        "fluxo mássico dos gases";
        input Real T_s(unit="K", displayUnit="degC", start=800)
        "temperatura dos gases de entrada da passagem de tubos";
        input Real q_s(unit="kW", start=400)
        "fluxo de energia de entrada da passagem de tubos";

        Real q_rad_1(unit="kW")
        "fluxo de calor por radiação da passagem de tubos";
        Real q_conv_1(unit="kW")
        "fluxo de calor por convecção da passagem de tubos";
        output Real q_1(unit="kW")
        "fluxo de energia de saída da passagem de tubos";

        Real cp_1(unit="kJ/(kg.degC)")
        "calor específico dos gases de saída da passagem de tubos";
        Real h_1(unit="kJ/kg")
        "entalpia dos gases de saída da passagem de tubos";

        output Real T_1(unit="K", displayUnit="degC")
        "temperatura dos gases de saída da passagem de tubos";
        Real T_1_med(unit="K", displayUnit="degC")
        "temperatura dos gases média da passagem de tubos";
        Real T_metal(unit="K", displayUnit="degC")
        "temperatura dos tubos de metal média da passagem de tubos";

    equation
        T_metal = T_sat;
        q_s - q_1 - q_rad_1 - q_conv_1 = 0;

        cp_1 = calor_especifico_gas(to_celsius(T_1));

        q_rad_1 = alpha_rad_1*(to_celsius(T_1_med)^4 - to_celsius(T_metal)^4);
        q_conv_1 = alpha_conv_1*(to_celsius(T_1_med) - to_celsius(T_metal));

        q_1 = m_g*h_1;
        h_1 = cp_1*T_1 - cp_ref*to_kelvin(T_ref);

        T_1_med = (T_s + T_1)/2;
    end PassagemTubos;

    model EconomizadorGases
        input Real m_g(unit="kg/s", start=4.495)
        "fluxo mássico dos gases";

        input Real q_1(unit="kW", start=400)
        "fluxo de energia de entrada do economizador";
        output Real q_rad_ec(unit="kW")
        "fluxo de calor por radiação do economizador";
        output Real q_conv_ec(unit="kW")
        "fluxo de calor por convecção do economizador";
        output Real q_ec(unit="kW")
        "fluxo de calor de saída do economizador";
    
        Real h_ec(unit="kJ/kg")
        "entalpia dos gases de saída do economizador";
        Real cp_ec(unit="kJ/(kg.degC)")
        "calor específico dos gases de saída do economizador";

        input Real T_1(unit="K", displayUnit="degC", start=800)
        "temperatura dos gases de entrada do economizador";
        Real T_ec(unit="K", displayUnit="degC")
        "temperatura dos gases de saída do economizador";
        input Real T_agua(unit="K", displayUnit="degC", start=400)
        "temperatura da água de entrada do economizador";
        input Real T_f(unit="K", displayUnit="degC", start=450)
        "temperatura da água de saída do economizador";
        Real T_ec_med(unit="K", displayUnit="degC")
        "temperatura dos gases média do economizador";
        Real T_metal_ec(unit="K", displayUnit="degC")
        "temperatura dos tubos de metal média do economizador";

    equation
        q_1 - q_ec - q_rad_ec - q_conv_ec = 0;

        cp_ec = calor_especifico_gas(to_celsius(T_ec));
        q_rad_ec = alpha_rad_ec*(to_celsius(T_1)^4 - to_celsius(T_metal_ec)^4);
        q_conv_ec = alpha_conv_ec*(to_celsius(T_1) - to_celsius(T_metal_ec));

        h_ec = cp_ec*T_ec - cp_ref*to_kelvin(T_ref);
        q_ec = m_g*h_ec;
        T_ec_med = (T_ec + T_1)/2;

        T_metal_ec = (T_agua + T_f)/2;
    end EconomizadorGases;
    
    model EconomizadorAgua
        input Real m_agua(unit="kg/s", start=1.927)
        "fluxo mássico de água de entrada do economizador";
        output Real m_f(unit="kg/s")
        "fluxo mássico de água de saída do economizador";

        input Real q_agua(unit="kW", start=100)
        "fluxo de energia da água de entrada do economizador";
        output Real q_f(unit="kW")
        "fluxo de energia de saída do economizador";
        input Real q_rad_ec(unit="kW", start=100)
        "fluxo de calor por radiação do economizador";
        input Real q_conv_ec(unit="kW", start=100)
        "fluxo de calor por convecção do economizador";
        output Real q_conv_ec_f(unit="kW")
        "fluxo de calor por convecção para a água do economizador";
    
        Real cp_f(unit="kJ/(kg.degC)")
        "calor específico da água de saída do economizador";
        Real h_f(unit="kJ/kg")
        "entalpia da água de saída do economizador";

        input Real T_agua(unit="K", displayUnit="degC", start=105+273)
        "temperatura da água de entrada do economizador";
        output Real T_f(unit="K", displayUnit="degC")
        "temperatura da água de saída do economizador";

    equation
        m_f = m_agua;
        q_agua - q_f + q_conv_ec_f = 0;
    
        cp_f = calor_especifico_agua(to_celsius(T_f));

        q_conv_ec_f = q_rad_ec + q_conv_ec;

        h_f = cp_f*T_f - cp_ref*T_ref;
        q_f = m_f*h_f;
    end EconomizadorAgua;

    model PreAquecedorGases
        input Real m_g(unit="kg/s", start=4.495)
        "fluxo mássico dos gases";
        input Real q_ec(unit="kW", start=100)
        "fluxo de energia da água de entrada do pré-aquecedor";
        output Real q_pre(unit="kW")
        "fluxo de energia de saída do pré-aquecedor";
        output Real q_conv_pre(unit="kW")
        "fluxo de calor por convecção do pré-aquecedor";
    
        Real cp_pre(unit="kJ/(kg.degC)")
        "calor específico dos gases de saída do pré-aquecedor";
        Real h_pre(unit="kJ/kg")
        "entalpia da água de saída do pré-aquecedor";

        input Real T_ec(unit="K", displayUnit="degC", start=300)
        "temperatura dos gases de entrada do pré-aquecedor";
        input Real T_ar(unit="K", displayUnit="degC", start=100)
        "temperatura do ar de saída do pré-aquecedor";
        output Real T_pre(unit="K", displayUnit="degC")
        "temperatura dos gases de saída do pré-aquecedor";
        Real T_pre_med(unit="K", displayUnit="degC")
        "temperatura dos gases média do pré-aquecedor";
        Real T_metal_pre(unit="K", displayUnit="degC")
        "temperatura dos gases média do pré-aquecedor";

    equation
        q_ec - q_pre - q_conv_pre = 0;
    
        cp_pre = calor_especifico_gas(to_celsius(T_pre));

        h_pre = cp_pre*T_pre - cp_ref*T_ref;
        q_pre = m_g*h_pre;

        q_conv_pre = alpha_conv_pre*(T_pre_med - T_metal_pre);

        T_pre_med = (T_ec + T_pre)/2;
        T_metal_pre = (T_ec + T_pre + T_ref + T_ar)/4;
    end PreAquecedorGases;

    model PreAquecedorAr
        input Real q_ar_in(unit="kW", start=100)
        "fluxo de energia do ar de entrada do pré-aquecedor";
        output Real q_ar_out(unit="kW", start=200)
        "fluxo de energia do ar de saída do pré-aquecedor";

        input Real q_conv_pre(unit="kW", start=200)
        "fluxo de calor por convecção do pré-aquecedor";
        output Real q_conv_pre_ar(unit="kW")
        "fluxo de calor por convecção para o ar do pré-aquecedor";
    
        Real cp_ar_out(unit="kJ/(kg.degC)")
        "calor específico do ar de saída do pré-aquecedor";
        Real h_ar_out(unit="kJ/kg")
        "entalpia do ar de saída do pré-aquecedor";

        input Real T_ar_in(unit="K", displayUnit="degC", start=100)
        "temperatura do ar de entrada do pré-aquecedor";
        output Real T_ar_out(unit="K", displayUnit="degC")
        "temperatura do ar de saída do pré-aquecedor";

    equation
        q_ar_in - q_ar_out + q_conv_pre_ar = 0;
    
        cp_ar_out = calor_especifico_ar(to_celsius(T_ar_out));

        q_conv_pre_ar = q_conv_pre;

        h_ar_out = cp_ar_out*T_ar_out - cp_ref*T_ref;
        q_ar_out = m_ar*h_ar_out;

    end PreAquecedorAr;

  model Dessuperaquecedor
      input Real m_sv(unit="kg/s", start=2)
      "fluxo mássico de vapor de entrada do dessuperaquecedor";
      output Real m_tur(unit="kg/s")
      "fluxo mássico de vapor de entrada do dessuperaquecedor";
  
      input Real q_sv(unit="kW", start=300)
      "fluxo de energia do vapor de entrada do dessuperaquecedor";
      input Real q_spray(unit="kW", start=100)
      "fluxo de energia da água de entrada do dessuperaquecedor";
      output Real q_tur(unit="kW")
      "fluxo de energia do vapor de saída do dessuperaquecedor";
  
      Real cp_tur(unit="kJ/(kg.degC)")
      "calor específico do vapor de saída do dessuperaquecedor";
      Real h_tur(unit="kJ/kg")
      "entalpia do vapor de saída do dessuperaquecedor";
  
      Real T_tur(unit="K", displayUnit="degC")
      "temperatura do vapor de saída do dessuperaquecedor";
  
  equation
      m_tur - m_spray - m_sv = 0;
      q_tur - q_sv - q_spray = 0;
      
      cp_tur = calor_especifico_agua(T_tur);
      q_tur = m_tur*h_tur;
      h_tur = cp_tur*T_tur - cp_ref*to_kelvin(T_ref);
  
  end Dessuperaquecedor;

    model Tambor
        Real p(unit="bar", start=27)
        "pressão";

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

        Real Q(unit="kW")
        "fluxo de calor";

        Real m_f(unit="kg/s")
        "fluxo mássico de água de entrada do tubulão";
        input Real m_v1(unit="kg/s", start=1.927)
        "fluxo mássico de água de saída do tubulão";

        Real V_v1(unit="m3", start=2)
        "volume de vapor";
        Real V_wt(unit="m3")
        "volume de água";
        constant Real V_t(unit="m3") = 14.4645
        "volume total";

        constant Real m_t(unit="kg") = 12324.333
        "massa do metal";
        constant Real cp_metal(unit="kJ/(kg.degC)") = 0.550
        "calor específico do metal";
        Real t_metal(unit="K")
        "temperatura do metal";

    equation
        p = 27 + 0.1*sin(time/100);
        V_v1 = 2 + 0.1*sin(time/100);
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

    constant Real m_fuel(unit="kg/s") = 0.7942
    "fluxo mássico de combustível";
    constant Real m_ar(unit="kg/s") = 3.7008
    "fluxo mássico de ar pré-aquecido";
    constant Real m_v1(unit="kg/s") = 1.927
    "fluxo mássico de vapor";
    constant Real m_tur(unit="kg/s") = 2.0833
    "fluxo mássico de água de saída do dessuperaquecedor";
    constant Real m_spray(unit="kg/s") = 0.1564
    "fluxo mássico de água de entrada do dessuperaquecedor";
    constant Real PCI(unit="kJ/kg") = 8223
    "poder calorífico inferior do combustível";
    constant Real cp_ref(unit="kJ/(kg.degC)") = 1.007
    "calor específico do ar ambiente";
    constant Real T_ref(unit="degC") = 25
    "temperatura ambiente";
    constant Real T_sat(unit="degC") = 228
    "temperatura de saturação da água/vapor em regime permanente";
    constant Real t_agua(unit="degC") = 105
    "temperatura da água de alimentação";
    constant Real h_f(unit="kJ/kg") = 441.841
    "entalpia da água de alimentação";

    constant Real alpha_rad_f(unit="kW/(degC4)") = 3.5721e-10
    "constante de calor por radiação da fornalha";
    constant Real alpha_conv_f(unit="kW/degC") = 0.3758
    "constante de calor por convecção da fornalha";
    constant Real alpha_rad_ev(unit="kW/K4") = 7.8998e-11
    "constante de calor por radiação do evaporador";
    constant Real alpha_conv_ev(unit="kW/K") = 0.8865
    "constante de calor por convecção do evaporador";
    constant Real alpha_rad_s(unit="kW/(degC4)") = 2.2e-10
    "constante de calor por radiação do superaquecedor";
    constant Real alpha_conv_s(unit="kW/degC") = 2.25
    "constante de calor por convecção do superaquecedor";
    constant Real alpha_rad_1(unit="kW/(degC4)") = 4.423e-10
    "constante de calor por radiação da passagem";
    constant Real alpha_conv_1(unit="kW/degC") = 5.14
    "constante de calor por convecção da passagem";
    constant Real alpha_rad_ec(unit="kW/(degC4)") = 3.3634e-10
    "constante de calor por radiação do economizador";
    constant Real alpha_conv_ec(unit="kW/degC") = 2.2556
    "constante de calor por convecção do economizador";
    constant Real alpha_conv_pre(unit="kW/degC") = 5.8235
    "constante de calor por convecção do pré-aquecedor";

    Fornalha fornalha;
    Evaporador evaporador;
    SuperAquecedorGases superaquecedor_gases;
    SuperAquecedorVapor superaquecedor_vapor;
    PassagemTubos passagem_tubos;
    EconomizadorGases economizador_gases;
    EconomizadorAgua economizador_agua;
    PreAquecedorGases preaquecedor_gases;
    PreAquecedorAr preaquecedor_ar;
    Dessuperaquecedor dessuperaquecedor;
    Tambor tambor;
equation
    fornalha.T_ar_out = preaquecedor_ar.T_ar_out;
    fornalha.q_ar_out = preaquecedor_ar.q_ar_out;

    evaporador.q_g = fornalha.q_g;
    evaporador.m_g = fornalha.m_g;
    evaporador.T_g = fornalha.T_g;

    superaquecedor_gases.m_g = fornalha.m_g; 
    superaquecedor_gases.T_ev = evaporador.T_ev; 
    superaquecedor_gases.q_ev = evaporador.q_ev;
    superaquecedor_gases.T_sv = superaquecedor_vapor.T_sv;

    superaquecedor_vapor.q_v1 =

    passagem_tubos.m_g = fornalha.m_g;
    passagem_tubos.T_s = superaquecedor.T_s;
    passagem_tubos.q_s = superaquecedor.q_s;
    
    

    economizador_gases.m_g = fornalha.m_g;
    economizador_gases.q_1 = passagem_tubos.q_1;
    economizador_gases.T_1 = passagem_tubos.T_1;
    economizador_gases.T_agua = t_agua;
    economizador_gases.T_f = economizador_agua.T_f;

    economizador_agua.q_rad_ec = economizador_gases.q_rad_ec;
    economizador_agua.q_conv_ec = economizador_gases.q_conv_ec;
    = economizador_gases.q_ec;

    economizador_agua.m_agua =
    economizador_agua.q_agua =
    economizador_agua.T_agua = t_agua;

    = economizador_agua.q_conv_ec_f;
    = economizador_gases.m_f;
    = economizador_gases.q_conv_ec;
    = economizador_gases.q_ec;

    preaquecedor_gases.T_ar = preaquecedor_ar.T_ar_out;
    
end Completo;
