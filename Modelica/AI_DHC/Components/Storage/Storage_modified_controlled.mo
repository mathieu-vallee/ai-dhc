within AI_DHC.Components.Storage;
model Storage_modified_controlled

  Stratified_modified Stock(
    redeclare package Medium = Medium,
    m_flow_nominal=0.1,
    VTan=VTan,
    hTan=hTan,
    dIns=dIns,
    kIns=kIns,
    nSeg=nSeg,
    tau=tau)
    annotation (Placement(transformation(extent={{-26,4},{26,56}})));
  parameter Modelica.Units.SI.Volume VTan "Tank volume";
  parameter Modelica.Units.SI.Length hTan
    "Height of tank (without insulation)";
  parameter Modelica.Units.SI.Length dIns "Thickness of insulation";
  parameter Modelica.Units.SI.ThermalConductivity kIns=0.05
    "Specific heat conductivity of insulation";
  parameter Integer nSeg=2 "Number of volume segments";
  parameter Modelica.Units.SI.Time tau=1 "Time constant for mixing";
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium
    annotation (__Dymola_choicesAllMatching=true);
  Modelica.Blocks.Interfaces.RealInput Power_decharge "Discharge Power in W"
    annotation (Placement(transformation(extent={{-128,42},{-88,82}})));
  Modelica.Blocks.Interfaces.RealInput Power_charge "Charge Power in W"
    annotation (Placement(transformation(extent={{-132,-48},{-92,-8}})));
  Modelica.Blocks.Interfaces.RealInput mMax_charge "Max Charging flow"
    annotation (Placement(transformation(extent={{-126,-86},{-86,-46}})));
  Modelica.Blocks.Interfaces.RealInput mMax_decharge "Max Discharging Flow"
    annotation (Placement(transformation(extent={{-128,10},{-88,50}})));
  Modelica.Blocks.Interfaces.RealOutput HeatLoss
    "Heat loss of tank (negative if heat flows from tank to ambient)"
    annotation (Placement(transformation(extent={{100,52},{120,72}})));
  Modelica.Blocks.Interfaces.RealOutput FlowCharge
    annotation (Placement(transformation(extent={{100,16},{120,36}})));
  Modelica.Blocks.Interfaces.RealOutput FlowDischarge
    annotation (Placement(transformation(extent={{100,-8},{120,12}})));
  Modelica.Blocks.Interfaces.RealOutput Pcharge_real
    annotation (Placement(transformation(extent={{100,-38},{120,-18}})));
  Modelica.Blocks.Interfaces.RealOutput Pdischarge_real
    annotation (Placement(transformation(extent={{102,-74},{122,-54}})));
  Modelica.Blocks.Sources.BooleanExpression ChargeMode(y=Power_charge > 1)
    "1 if charge mode"
    annotation (Placement(transformation(extent={{76,86},{96,106}})));
  Modelica.Blocks.Sources.BooleanExpression DechargeMode(y=Power_decharge >
        1) "1 if Discharge"
    annotation (Placement(transformation(extent={{76,70},{96,90}})));
  EnR_SIM.Stage_Collette.BaseClasses.Control_P_continu Decharge_Control(gainP=1)
    annotation (Placement(transformation(extent={{-74,44},{-56,60}})));
  EnR_SIM.Stage_Collette.BaseClasses.Control_P_continu Charge_Control(gainP=1)
    annotation (Placement(transformation(extent={{-74,-48},{-56,-32}})));
  Modelica.Blocks.Sources.RealExpression min_flow(y=0)
    annotation (Placement(transformation(extent={{9,-10},{-9,10}},
        rotation=180,
        origin={-75,-92})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TBCSid1
    "Boundary condition for tank" annotation (Placement(transformation(extent={{36,86},
            {48,98}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TBCTop1
    "Boundary condition for tank" annotation (Placement(transformation(extent={{36,70},
            {48,82}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TBCBot
    "Boundary condition for tank"
    annotation (Placement(transformation(extent={{38,54},{50,66}})));
  Modelica.Blocks.Interfaces.RealInput Text "Outside temperature" annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=270,
        origin={-10,110})));
  Modelica.Blocks.Sources.RealExpression Pcharge_recalc(y=if ChargeMode.y
         then -Stock.Pdecharge else 0)
    annotation (Placement(transformation(extent={{26,-102},{88,-76}})));
  Modelica.Blocks.Sources.RealExpression Pdecharge_recalc(y=if DechargeMode.y
         then Stock.Pdecharge else 0)
    annotation (Placement(transformation(extent={{24,-74},{86,-48}})));
  Modelica.Blocks.Sources.RealExpression Debit_Charge1(y=if ChargeMode.y
         then Charge_Control.Output else 0)
    annotation (Placement(transformation(extent={{-170,-80},{-134,-54}})));
  Modelica.Blocks.Sources.RealExpression Debit_Decharge(y=if DechargeMode.y
         then Decharge_Control.Output else 0)
    annotation (Placement(transformation(extent={{-162,-108},{-126,-82}})));
  Modelica.Blocks.Interfaces.RealInput KIns_Modifier "Value between 0 and 1"
    annotation (Placement(transformation(extent={{-132,-18},{-92,22}})));
   Modelica.Fluid.Interfaces.FluidPort_b C0_out(redeclare package Medium =
        Medium) "Fluid port for charging the storage (cold)" annotation (
      Placement(transformation(extent={{-6,-134},{20,-110}}),
        iconTransformation(extent={{92,-152},{118,-128}})));
  Modelica.Fluid.Interfaces.FluidPort_a D1_In(redeclare package Medium =
        Medium)
    "Fluid port for discharging the storage (cold)" annotation (Placement(
        transformation(extent={{-34,-134},{-8,-110}}),
                                                     iconTransformation(extent={
            {6,-152},{32,-128}})));
  Modelica.Fluid.Interfaces.FluidPort_b D1_Out(redeclare package Medium =
        Medium) "Fluid port for discharging the storage (warm)" annotation (
      Placement(transformation(extent={{-94,92},{-66,118}}),
                                                           iconTransformation(
          extent={{6,146},{34,172}})));
  Modelica.Fluid.Interfaces.FluidPort_a C0_In(redeclare package Medium =
        Medium)
    "Fluid port for charging the storage (warm)" annotation (Placement(
        transformation(extent={{-54,92},{-28,116}}), iconTransformation(extent={
            {92,146},{118,170}})));
  Pump.ImposeMflow D1_pump_bot(redeclare package Medium = Medium,
      allowFlowReversal=false)                                    annotation (
      Placement(transformation(
        extent={{-13,-15},{13,15}},
        rotation=90,
        origin={-21,-75})));
  Pump.ImposeMflow C0_pump_bot(redeclare package Medium = Medium,
      allowFlowReversal=false) annotation (Placement(transformation(
        extent={{-13,-15},{13,15}},
        rotation=270,
        origin={5,-77})));
  Pump.ImposeMflow D1_pump_top(redeclare package Medium = Medium,
      allowFlowReversal=false) annotation (Placement(transformation(
        extent={{-13,-15},{13,15}},
        rotation=90,
        origin={-61,83})));
  Pump.ImposeMflow C0_pump_top(redeclare package Medium = Medium,
      allowFlowReversal=false) annotation (Placement(transformation(
        extent={{-13,-15},{13,15}},
        rotation=270,
        origin={-31,73})));
  Fluid.Vessels.ClosedVolume Tank_Bottom(
    V=0.001,
    nPorts=3,
    redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{-13,-13},{13,13}},
        rotation=270,
        origin={35,-29})));
  Fluid.Vessels.ClosedVolume Tank_Top(
    V=0.001,
    nPorts=3,
    redeclare package Medium = Medium) annotation (Placement(transformation(
        extent={{-13,-13},{13,13}},
        rotation=90,
        origin={-61,23})));
equation
  connect(Charge_Control.umin, min_flow.y) annotation (Line(points={{-74.9,
          -44.64},{-80,-44.64},{-80,-78},{-58,-78},{-58,-92},{-65.1,-92}},
        color={0,0,127}));
  connect(min_flow.y, Decharge_Control.umin) annotation (Line(points={{-65.1,
          -92},{-58,-92},{-58,-78},{-80,-78},{-80,47.36},{-74.9,47.36}},
        color={0,0,127}));
  connect(Decharge_Control.umax, mMax_decharge) annotation (Line(points={{
          -74.9,58.56},{-82,58.56},{-82,30},{-108,30}}, color={0,0,127}));
  connect(mMax_charge, Charge_Control.umax) annotation (Line(points={{-106,
          -66},{-46,-66},{-46,-24},{-74.9,-24},{-74.9,-33.44}}, color={0,0,
          127}));
  connect(Power_decharge, Decharge_Control.Setpoint) annotation (Line(points=
         {{-108,62},{-80,62},{-80,54.24},{-74.72,54.24}}, color={0,0,127}));
  connect(Power_charge, Charge_Control.Setpoint) annotation (Line(points={{
          -112,-28},{-84,-28},{-84,-37.76},{-74.72,-37.76}}, color={0,0,127}));
  connect(TBCBot.T,Text)
    annotation (Line(points={{36.8,60},{14,60},{14,90},{-10,90},{-10,110}},
                                                             color={0,0,127}));
  connect(TBCSid1.T,Text)
    annotation (Line(points={{34.8,92},{12,92},{12,90},{-10,90},{-10,110}},
                                                             color={0,0,127}));
  connect(TBCTop1.T,Text)
    annotation (Line(points={{34.8,76},{14,76},{14,90},{-10,90},{-10,110}},
                                                             color={0,0,127}));
  connect(TBCBot.port, Stock.heaPorBot) annotation (Line(points={{50,60},{54,
          60},{54,-2},{4,-2},{4,6},{5.2,6},{5.2,10.76}}, color={191,0,0}));
  connect(TBCTop1.port, Stock.heaPorSid) annotation (Line(points={{48,76},{
          56,76},{56,30},{14.56,30}}, color={191,0,0}));
  connect(TBCSid1.port, Stock.heaPorTop) annotation (Line(points={{48,92},{
          52,92},{52,68},{4,68},{4,54},{5.2,54},{5.2,49.24}}, color={191,0,0}));
  connect(Pdecharge_recalc.y, Pdischarge_real) annotation (Line(points={{
          89.1,-61},{98,-61},{98,-64},{112,-64}}, color={0,0,127}));
  connect(Pcharge_recalc.y, Pcharge_real) annotation (Line(points={{91.1,-89},
          {94,-89},{94,-28},{110,-28}}, color={0,0,127}));
  connect(Pdecharge_recalc.y, Decharge_Control.Measure) annotation (Line(
        points={{89.1,-61},{88,-61},{88,-6},{-78,-6},{-78,51.36},{-74.72,
          51.36}}, color={0,0,127}));
  connect(Pcharge_recalc.y, Charge_Control.Measure) annotation (Line(points=
          {{91.1,-89},{94,-89},{94,-40},{-48,-40},{-48,-54},{-82,-54},{-82,
          -40.64},{-74.72,-40.64}}, color={0,0,127}));
  connect(Stock.Ql_flow, HeatLoss) annotation (Line(points={{28.6,48.72},{92,
          48.72},{92,62},{110,62}}, color={0,0,127}));
  connect(Stock.kIns_Ext_Modifier, KIns_Modifier) annotation (Line(points={{
          -27.04,14.92},{-82,14.92},{-82,2},{-112,2}}, color={0,0,127}));
  connect(D1_In, D1_pump_bot.port_a)
    annotation (Line(points={{-21,-122},{-21,-88}}, color={0,127,255}));
  connect(C0_out, C0_pump_bot.port_b)
    annotation (Line(points={{7,-122},{5,-122},{5,-90}}, color={0,127,255}));
  connect(D1_Out, D1_pump_top.port_b) annotation (Line(points={{-80,105},{-80,88},
          {-98,88},{-98,120},{-61,120},{-61,96}}, color={0,127,255}));
  connect(C0_In, C0_pump_top.port_a)
    annotation (Line(points={{-41,104},{-41,86},{-31,86}}, color={0,127,255}));
  connect(Debit_Charge1.y, C0_pump_top.Mflow) annotation (Line(points={{-132.2,-67},{-110,-67},{-110,-76},{20,-76},{20,-66},{22,-66},{22,-60},{10,-60},{10,-56},{-12,-56},
          {-12,-8},{28,-8},{28,0},{34,0},{34,54},{30,54},{30,70},{-10,70},{-10,83.4},{-20.75,83.4}},
                                                         color={0,0,127}));
  connect(Debit_Charge1.y, C0_pump_bot.Mflow) annotation (Line(points={{-132.2,-67},{-110,-67},{-110,-76},{20,-76},{20,-66.6},{15.25,-66.6}},
                                                         color={0,0,127}));
  connect(Debit_Decharge.y, D1_pump_bot.Mflow) annotation (Line(points={{-124.2,-95},{-88,-95},{-88,-106},{-30,-106},{-30,-90},{-31.25,-90},{-31.25,-85.4}},
                   color={0,0,127}));
  connect(Debit_Decharge.y, D1_pump_top.Mflow) annotation (Line(points={{-124.2,-95},{-88,-95},{-88,-106},{-30,-106},{-30,-92},{-38,-92},{-38,-90},{-42,-90},{-42,56},
          {-50,56},{-50,64},{-70,64},{-70,68},{-71.25,68},{-71.25,72.6}},
                         color={0,0,127}));
  connect(D1_pump_top.port_a, Tank_Top.ports[1]) annotation (Line(points={{-61,70},{-64,70},{-64,62},{-48,62},{-48,52},{-40,52},{-40,19.5333},{-48,19.5333}},
                     color={0,127,255}));
  connect(C0_pump_top.port_b, Tank_Top.ports[2]) annotation (Line(points={{-31,
          60},{-31,36},{-40,36},{-40,20},{-48,20},{-48,23}}, color={0,127,255}));
  connect(Tank_Top.ports[3], Stock.port_a) annotation (Line(points={{-48,26.4667},{-48,20},{-40,20},{-40,36},{-32,36},{-32,30},{-26,30}},
                                                                  color={0,127,
          255}));
  connect(Stock.port_b, Tank_Bottom.ports[1]) annotation (Line(points={{26,30},{26,-10},{14,-10},{14,-25.5333},{22,-25.5333}},
                                                         color={0,127,255}));
  connect(Tank_Bottom.ports[2], D1_pump_bot.port_b) annotation (Line(points={{22,
          -29},{12,-29},{12,-54},{-21,-54},{-21,-62}}, color={0,127,255}));
  connect(C0_pump_bot.port_a, Tank_Bottom.ports[3]) annotation (Line(points={{5,-64},{4,-64},{4,-54},{12,-54},{12,-32.4667},{22,-32.4667}},
                                                                      color={0,
          127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -120},{100,100}})),                                  Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-100,-120},{100,100}})));
end Storage_modified_controlled;
