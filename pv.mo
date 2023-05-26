model pv
    output Real p(unit="bar", start=27);
    output Real ppascal(unit="Pa",start=2700000);

    output Real rho_v1(unit="kg/m3")
    "massa específica do vapor";
    output Real rho_wt(unit="kg/m3")
    "massa específica dá água";
    output Real h_v1(unit="kJ/kg")
    "entalpia do vapor";
    output Real h_wt(unit="kJ/kg")
    "entalpia do água";

    constant Real h_f(unit="kJ/kg") = 441.841
    "entalpia da água de alimentação";

    output Real u_wt, u_v1;
    constant Real Q(unit="W") = 45409000;

    output Real m_f(unit="kg/s", start=1.927)
    "fluxo mássico de água que entra no tubulão";
    constant Real m_v1(unit="kg/s") = 1.927
    "fluxo mássico de água que saí do tubulão";

    input Real V_v1(unit="m3", start=2)
    "volume total de vapor no sistema";
    constant Real V_wt(unit="m3", start=12.4645)
    "volume total de água no sistema";
    output Real V_t(unit="m3", start=14.4645)
    "volume total";

    constant Real m_t(unit="kg") = 12324.333
    "massa total do metal";
    constant Real cp_metal(unit="kJ/(kg.degC)") = 0.550
    "calor específico do metal";
    output Real t_metal(unit="K", start=228+273)
    "temperatura do metal";

    Real q_v1;
    Real q_wt;
    Real q_metal;
    Real dq;

    Real dm_v1;
    Real dm_wt;
    Real dm;
equation
    V_t = V_v1 + V_wt;

    rho_v1  = 0.02772*p^2 - 4.14272*p + 921.4526;
    rho_wt = 0.0006*p^2 + 0.46795*p + 0.4615;
    t_metal  = -0.0325*p^2 + 3.7675*p + 150.055 + 273;
    h_v1  = -0.0457*p^2 + 2.7905*p + 2758.3;
    h_wt  = -0.1317*p^2 + 16.533*p + 630.33;

    ppascal = p*100000;
    u_v1 = h_v1 - 1000*(ppascal/rho_v1);
    u_wt = h_wt - 1000*(ppascal/rho_wt);

    dm_v1 = rho_v1*V_v1;
    dm_wt = rho_wt*V_wt;
    dm = dm_v1 + dm_wt;
    m_f - m_v1 = der(rho_v1*V_v1 + rho_wt*V_wt);

    q_v1 = rho_v1*u_v1*V_v1;
    q_wt = rho_wt*u_wt*V_wt;
    q_metal = m_t*cp_metal*t_metal;
    dq = q_v1 + q_wt + q_metal;
    Q + m_f*h_f - m_v1*h_v1 = der(dq);
end pv;
