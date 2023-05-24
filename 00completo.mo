model completo
    screen screen1 annotation(
    Placement(visible = true, transformation(origin = {30, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    fornalha fornalha1 annotation(
    Placement(visible = true, transformation(origin = {-34, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    Modelica.Blocks.Sources.Constant T_ar_out(k = 100)  annotation(
    Placement(visible = true, transformation(origin = {-76, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
    connect(fornalha1.q_g, screen1.q_g) annotation(
    Line(points = {{-27, -7}, {21, -7}, {21, -5}}, color = {0, 0, 127}));
    connect(fornalha1.T_g, screen1.T_g) annotation(
    Line(points = {{-27, 7}, {23, 7}, {23, 3}}, color = {0, 0, 127}));
    connect(T_ar_out.y, fornalha1.T_ar_out) annotation(
    Line(points = {{-64, 0}, {-40, 0}}, color = {0, 0, 127}));
    annotation(
    uses(Modelica(version = "4.0.0")));
end completo;
