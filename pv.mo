model pv
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

    rho_v1  = 0.336208    + 0.483024*p - 0.000048*p^2 - 0.000008*p^3;
    rho_wt  = 932.309732  - 5.454961*p + 0.080024*p^2 - 0.000687*p^3;
    t_metal = 408.707924  + 5.521758*p - 0.102524*p^2 + 0.000922*p^3;
    h_v1    = 2731.845759 + 5.941585*p - 0.169762*p^2 + 0.001615*p^3;
    h_wt    = 578.773728 + 22.682809*p - 0.373929*p^2 + 0.003151*p^3;

    u_v1 = h_v1 - 1000*(p/rho_v1);
    u_wt = h_wt - 1000*(p/rho_wt);
    
    m_f - m_v1 = der(rho_v1*V_v1 + rho_wt*V_wt);

    Q + m_f*h_f - m_v1*h_v1 = der(rho_v1*u_v1*V_v1 + rho_wt*u_wt*V_wt + m_t*cp_metal*t_metal);

end pv;
