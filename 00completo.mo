model completo
  Modelica.Blocks.Sources.Constant const(k = 10)  annotation(
    Placement(visible = true, transformation(origin = {-62, -2}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  fornalha fornalha1 annotation(
    Placement(visible = true, transformation(origin = {32, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(const.y, fornalha1.T_ar_out) annotation(
    Line(points = {{-50, -2}, {28, -2}, {28, 2}}, color = {0, 0, 127}));
  annotation(
    uses(Modelica(version = "4.0.0")));
end completo;