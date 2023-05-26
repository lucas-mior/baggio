model pv
    output Real p(unit="bar", start=27);
    output Real ppascal(unit="Pa",start=2700000);

    output Real rho_v1(unit="kg/m3", start=13.497)
    "massa específica do vapor";
    output Real rho_wt(unit="kg/m3", start=829.830)
    "massa específica dá água";
    output Real h_v1(unit="kJ/kg", start=2800.30)
    "entalpia do vapor";
    output Real h_wt(unit="kJ/kg", start=980.64)
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

    rho_v1  = 0.336208    + 0.483024*p - 0.000048*p^2 - 0.000008*p^3;
    rho_wt  = 932.309732  - 5.454961*p + 0.080024*p^2 - 0.000687*p^3;
    t_metal = 408.707924  + 5.521758*p - 0.102524*p^2 + 0.000922*p^3;
    h_v1    = 2731.845759 + 5.941585*p - 0.169762*p^2 + 0.001615*p^3;
    h_wt    = 578.773728 + 22.682809*p - 0.373929*p^2 + 0.003151*p^3;

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
