within AI_DHC.Components.BaseClass;
model Control_P_continu
  parameter Real gainP = 0.02 "Proportionnal gain";

    parameter Boolean strict=false "= true, if strict limits with noEvent(..)"
    annotation (Evaluate=true, choices(checkBox=true));

  Modelica.Blocks.Math.Gain gain(k=gainP)
    annotation (Placement(transformation(extent={{-14,12},{6,32}})));
  Modelica.Blocks.Interfaces.RealInput Difference
    "Setpoint - Signal" annotation (Placement(transformation(
          extent={{-128,0},{-88,40}}), iconTransformation(extent={{-128,0},{-88,
            40}})));
  Modelica.Blocks.Nonlinear.VariableLimiter variableLimiter(strict=strict)
    annotation (Placement(transformation(extent={{38,10},{58,30}})));
  Modelica.Blocks.Interfaces.RealOutput Output
    "Connector of Real output signal"
    annotation (Placement(transformation(extent={{102,6},{128,32}})));
  Modelica.Blocks.Interfaces.RealInput umax "Connector of Real input signal 1"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={10,100}), iconTransformation(
        extent={{-12,-12},{12,12}},
        rotation=-90,
        origin={2,92})));
  Modelica.Blocks.Interfaces.RealInput umin "Connector of Real input signal 1"
    annotation (Placement(transformation(
        extent={{20,-20},{-20,20}},
        rotation=-90,
        origin={0,-100}), iconTransformation(
        extent={{12,-12},{-12,12}},
        rotation=-90,
        origin={0,-96})));
equation
  connect(variableLimiter.u, gain.y) annotation (Line(points={{36,20},{22,20},{22,
          22},{7,22}}, color={0,0,127}));
  connect(variableLimiter.y, Output) annotation (Line(points={{59,20},{86,20},{86,
          19},{115,19}}, color={0,0,127}));
  connect(Difference, gain.u) annotation (Line(points={{-108,20},{-62,20},{-62,
          22},{-16,22}}, color={0,0,127}));
  connect(umax, variableLimiter.limit1) annotation (Line(points={{10,100},{12,
          100},{12,28},{36,28}}, color={0,0,127}));
  connect(umin, variableLimiter.limit2) annotation (Line(points={{0,-100},{0,0},
          {24,0},{24,12},{36,12}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end Control_P_continu;
