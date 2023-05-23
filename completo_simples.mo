model completo_simples
  simples simples1 annotation(
    Placement(visible = true, transformation(origin = {42, 36}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.Constant const(k = 8)  annotation(
    Placement(visible = true, transformation(origin = {-36, 2}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(const.y, simples1.u) annotation(
    Line(points = {{-24, 2}, {34, 2}, {34, 41}}, color = {0, 0, 127}));

annotation(
    uses(Modelica(version = "4.0.0")));
end completo_simples;