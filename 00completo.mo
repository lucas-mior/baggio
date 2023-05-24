model completo
  Modelica.Blocks.Sources.Constant const(k = 10)  annotation(
    Placement(visible = true, transformation(origin = {-62, -2}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  fornalha fornalha1 annotation(
    Placement(visible = true, transformation(origin = {-2, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  screen screen1 annotation(
    Placement(visible = true, transformation(origin = {56, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(const.y, fornalha1.T_ar_out) annotation(
    Line(points = {{-50, -2}, {-6, -2}, {-6, 2}}, color = {0, 0, 127}));
  connect(fornalha1.T_g, screen1.T_g) annotation(
    Line(points = {{6, 8}, {50, 8}, {50, 4}}, color = {0, 0, 127}));
  connect(fornalha1.q_g, screen1.q_g) annotation(
    Line(points = {{4, -6}, {26, -6}, {26, -4}, {48, -4}}, color = {0, 0, 127}));
  annotation(
    uses(Modelica(version = "4.0.0")));
end completo;