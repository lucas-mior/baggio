model conditions
    output Real m_fuel(unit = "kg/s")  = 0.7942 "Fluxo mássico de combustível";
    output Real m_ar(unit = "kg/s")    = 3.7008 "Fluxo mássico de ar";
    output Real m_v1(unit = "kg/s")    = 1.9270 "Fluxo mássico de vapor";
    output Real m_tur(unit = "kg/s")   = 2.0833 "Fluxo mássico de vapor saída do sistema";
    output Real m_spray(unit = "kg/s") = 0.1564 "Fluxo mássico do spray";

    output Real p(unit = "bar") = 27 "Pressão de operação";

    output Real PCI(unit = "kJ/kg") = 8223 "Poder calorífico inferior do combustível";

    output Real t_s(unit = "degC")    = 228 "Temperatura de saturação água/vapor";
    output Real t_agua(unit = "degC") = 105 "Temperatura da água de alimentação";
    output Real t_ref(unit = "degC")  = 25 "Temperatura ambiente ou referência";

    output Real V_st(unit = "m3") = 2 "Volume de vapor no Ponto de Operação";
    output Real V_wt(unit = "m3") = 12.4645 "Volume de água no Ponto de Operação";
    output Real V_t(unit = "m3")  = 14.4645 "Volume total";

    output Real m_t(unit = "kg") = 12324.333 "Massa total de metal";

    output Real cp_metal(unit = "kJ/(kg.degC)") = 0.550 "Calor específico do metal";

    output Real h_f(unit = "kJ/kg") = 441.841 "Entalpia água de alimentação";
end conditions;
