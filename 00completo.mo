model completo
    Modelica.Blocks.Sources.Constant T_ar_out(k = 100)  annotation(
    Placement(visible = true, transformation(origin = {-76, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    screen screen1 annotation(
    Placement(visible = true, transformation(origin = {62, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    fornalha fornalha1 annotation(
    Placement(visible = true, transformation(origin = {-4, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(T_ar_out.y, fornalha1.T_ar_out) annotation(
    Line(points = {{-64, 0}, {-10, 0}}, color = {0, 0, 127}));
  connect(fornalha1.T_g, screen1.T_g) annotation(
    Line(points = {{4, 8}, {56, 8}, {56, 6}}, color = {0, 0, 127}));
  connect(fornalha1.m_g, screen1.m_g) annotation(
    Line(points = {{4, 0}, {54, 0}}, color = {0, 0, 127}));
  connect(fornalha1.q_g, screen1.q_g) annotation(
    Line(points = {{4, -6}, {56, -6}}, color = {0, 0, 127}));
  annotation(
    uses(Modelica(version = "4.0.0")));
end completo;