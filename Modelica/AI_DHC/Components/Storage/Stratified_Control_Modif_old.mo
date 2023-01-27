within AI_DHC.Components.Storage;
model Stratified_Control_Modif_old
  "Stockage controlled by charge & discharge power"
    replaceable package Medium =
      Modelica.Media.Water.ConstantPropertyLiquidWater (T_max=273.15 + 1e5, T_min=273.15 - 1e5)
    constrainedby Modelica.Media.Interfaces.PartialMedium;
    // Parameters
  parameter Modelica.Units.SI.MassFlowRate DebitMax=10 "Maximum Flow Rate"
    annotation (Dialog(tab="General", group="Control"));
  parameter Modelica.Units.SI.Power PuissanceMax=500*1e3 "Maximum Power";

  Modelica.Blocks.Interfaces.RealInput kIns_Ext_Modifier "0 to 1"
    annotation (Placement(transformation(extent={{-20,-20},{20,20}},
        rotation=90,
        origin={-44,-128})));
  Modelica.Blocks.Interfaces.RealInput Text "Outside temperature" annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=270,
        origin={-42,110})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TBCSid1
    "Boundary condition for tank" annotation (Placement(transformation(extent={{-14,80},
            {-2,92}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TBCTop1
    "Boundary condition for tank" annotation (Placement(transformation(extent={{-14,60},
            {-2,72}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TBCBot
    "Boundary condition for tank"
    annotation (Placement(transformation(extent={{-14,44},{-2,56}})));
  Modelica.Blocks.Interfaces.RealInput Power_Discharge
    "Discharge Power in W"
    annotation (Placement(transformation(extent={{-248,38},{-208,78}})));
  Modelica.Blocks.Interfaces.RealInput Power_Charge "Charge Power in W"
    annotation (Placement(transformation(extent={{-252,-52},{-212,-12}})));
  Modelica.Blocks.Interfaces.RealInput mMax_Charge "Max Charging flow"
    annotation (Placement(transformation(extent={{-246,-90},{-206,-50}})));
  Modelica.Blocks.Interfaces.RealInput mMax_Discharge "Max Discharging Flow"
    annotation (Placement(transformation(extent={{-248,6},{-208,46}})));
  Modelica.Blocks.Sources.RealExpression min_flow(y=0)
    annotation (Placement(transformation(extent={{9,-10},{-9,10}},
        rotation=180,
        origin={-217,-106})));
  EnR_SIM.Stage_Collette.BaseClasses.Control_P_continu Discharge_control(gainP=
        DebitMax/PuissanceMax/0.02)
    annotation (Placement(transformation(extent={{-190,10},{-172,26}})));
  EnR_SIM.Stage_Collette.BaseClasses.Control_P_continu Charge_Control(gainP=
        DebitMax/PuissanceMax/0.02)
    annotation (Placement(transformation(extent={{-194,-56},{-176,-40}})));
  Modelica.Fluid.Interfaces.FluidPort_b D1_Out(redeclare package Medium = Medium)
                "Fluid port for discharging the storage (warm)" annotation (
      Placement(transformation(extent={{-172,88},{-144,114}}),
                                                           iconTransformation(
          extent={{6,146},{34,172}})));
  Modelica.Fluid.Interfaces.FluidPort_a C0_In(redeclare package Medium = Medium)
    "Fluid port for charging the storage (warm)" annotation (Placement(
        transformation(extent={{-132,88},{-106,112}}),
                                                     iconTransformation(extent={
            {92,146},{118,170}})));
   Modelica.Fluid.Interfaces.FluidPort_b C0_out(redeclare package Medium =
        Medium) "Fluid port for charging the storage (cold)" annotation (
      Placement(transformation(extent={{18,-134},{44,-110}}),
        iconTransformation(extent={{92,-152},{118,-128}})));
  Modelica.Fluid.Interfaces.FluidPort_a D1_In(redeclare package Medium = Medium)
    "Fluid port for discharging the storage (cold)" annotation (Placement(
        transformation(extent={{-12,-134},{14,-110}}),
                                                     iconTransformation(extent={
            {6,-152},{32,-128}})));
  Pump.ImposeMflow D1_pump_bot(redeclare package Medium = Medium,
      allowFlowReversal=false)                                    annotation (
      Placement(transformation(
        extent={{-13,-15},{13,15}},
        rotation=90,
        origin={-1,-81})));
  Pump.ImposeMflow C0_pump_bot(redeclare package Medium = Medium,
      allowFlowReversal=false)                                    annotation (
      Placement(transformation(
        extent={{13,13},{-13,-13}},
        rotation=90,
        origin={31,-85})));
  Pump.ImposeMflow D1_pump_top(redeclare package Medium = Medium,
      allowFlowReversal=false)                                    annotation (
      Placement(transformation(
        extent={{-13,-15},{13,15}},
        rotation=90,
        origin={-159,71})));
  Pump.ImposeMflow C0_pump_top(redeclare package Medium = Medium,
      allowFlowReversal=false)                                    annotation (
      Placement(transformation(
        extent={{13,13},{-13,-13}},
        rotation=90,
        origin={-119,71})));
  Fluid.Vessels.ClosedVolume Tank_Top(
    V=0.001,
    nPorts=2,
    redeclare package Medium = Medium) annotation (Placement(transformation(
        extent={{-13,-13},{13,13}},
        rotation=180,
        origin={-133,15})));
  Fluid.Vessels.ClosedVolume Tank_Bottom(
    V=0.001,
    nPorts=2,
    redeclare package Medium = Medium)
    annotation (Placement(transformation(extent={{28,-28},{54,-2}})));
  Modelica.Blocks.Sources.BooleanExpression ChargeMode(y=Power_charge > 1)
    "1 if charge mode"
    annotation (Placement(transformation(extent={{64,78},{84,98}})));
  Modelica.Blocks.Sources.BooleanExpression DischargeMode(y=Power_decharge > 1)
    "1 if Discharge"
    annotation (Placement(transformation(extent={{64,58},{84,78}})));
  Modelica.Blocks.Sources.RealExpression Debit_discharge_D1(y=if DischargeMode.y
         then Discharge_control.Output else 0)
    annotation (Placement(transformation(extent={{-254,74},{-192,100}})));
  Modelica.Blocks.Sources.RealExpression Debit_discharge_D2(y=if DischargeMode.y
         then Discharge_control.Output else 0)
    annotation (Placement(transformation(extent={{-122,-100},{-60,-74}})));
  Modelica.Blocks.Sources.RealExpression Debit_Charge(y=if ChargeMode.y then
        Charge_Control.Output else 0)
    annotation (Placement(transformation(extent={{88,-116},{52,-90}})));
  Modelica.Blocks.Sources.RealExpression Debit_Charge1(y=if ChargeMode.y then
        Charge_Control.Output else 0)
    annotation (Placement(transformation(extent={{-58,52},{-94,78}})));
  Modelica.Blocks.Sources.RealExpression Pcharge_recalc(y=if ChargeMode.y then -
        tan1.Pdecharge else 0)
    annotation (Placement(transformation(extent={{-134,-74},{-72,-48}})));
  Modelica.Blocks.Sources.RealExpression PDischarge_recalc(y=if DischargeMode.y
         then tan1.Pdecharge else 0)
    annotation (Placement(transformation(extent={{-172,-42},{-110,-16}})));
  Modelica.Blocks.Interfaces.RealOutput HeatLoss
    "Heat loss of tank (negative if heat flows from tank to ambient)"
    annotation (Placement(transformation(extent={{96,40},{116,60}})));
  Modelica.Blocks.Interfaces.RealOutput FlowCharge
    annotation (Placement(transformation(extent={{98,4},{118,24}})));
  Modelica.Blocks.Interfaces.RealOutput FlowDischarge
    annotation (Placement(transformation(extent={{98,-20},{118,0}})));
  Modelica.Blocks.Interfaces.RealOutput Pcharge_real
    annotation (Placement(transformation(extent={{96,-50},{116,-30}})));
  Modelica.Blocks.Interfaces.RealOutput Pdischarge_real
    annotation (Placement(transformation(extent={{100,-86},{120,-66}})));
  parameter Modelica.Units.SI.Volume VTan=Vtan "Tank volume";
  parameter Modelica.Units.SI.Length hTan=hTan
    "Height of tank (without insulation)";
  parameter Modelica.Units.SI.Length dIns=dIns "Thickness of insulation";
  parameter Modelica.Units.SI.ThermalConductivity kIns=kIns
    "Specific heat conductivity of insulation";
  parameter Integer nSeg=nSeg "Number of volume segments";
  parameter Modelica.Units.SI.Time tau=tau "Time constant for mixing";
equation
  connect(TBCBot.T, Text)
    annotation (Line(points={{-15.2,50},{-42,50},{-42,110}}, color={0,0,127}));
  connect(TBCSid1.T, Text)
    annotation (Line(points={{-15.2,86},{-42,86},{-42,110}}, color={0,0,127}));
  connect(TBCTop1.T, Text)
    annotation (Line(points={{-15.2,66},{-42,66},{-42,110}}, color={0,0,127}));
  connect(D1_In, D1_pump_bot.port_a)
    annotation (Line(points={{1,-122},{-1,-122},{-1,-94}}, color={0,127,255}));
  connect(C0_out, C0_pump_bot.port_b) annotation (Line(points={{31,-122},{30,-122},
          {30,-102},{31,-102},{31,-98}}, color={0,127,255}));
  connect(D1_Out, D1_pump_top.port_b)
    annotation (Line(points={{-158,101},{-159,84}}, color={0,127,255}));
  connect(C0_In, C0_pump_top.port_a)
    annotation (Line(points={{-119,100},{-119,84}}, color={0,127,255}));
  connect(D1_pump_bot.port_b, Tank_Bottom.ports[1]) annotation (Line(points={{-1,-68},
          {-1,-48},{30,-48},{30,-32},{38.4,-32},{38.4,-28}},
                                                      color={0,127,255}));
  connect(C0_pump_bot.port_a, Tank_Bottom.ports[2]) annotation (Line(points={{31,-72},
          {30,-72},{30,-32},{43.6,-32},{43.6,-28}},  color={0,127,255}));
  connect(D1_pump_top.port_a, Tank_Top.ports[1]) annotation (Line(points={{-159,58},
          {-159,34},{-130.4,34},{-130.4,28}},     color={0,127,255}));
  connect(C0_pump_top.port_b, Tank_Top.ports[2]) annotation (Line(points={{-119,58},
          {-119,32},{-135.6,32},{-135.6,28}},
                                          color={0,127,255}));
  connect(Discharge_control.umax, mMax_Discharge) annotation (Line(points={{-190.9,
          24.56},{-204,24.56},{-204,26},{-228,26}}, color={0,0,127}));
  connect(Discharge_control.Setpoint, Power_Discharge) annotation (Line(points={{
          -190.72,20.24},{-190.72,58},{-228,58}}, color={0,0,127}));
  connect(Discharge_control.umin, min_flow.y) annotation (Line(points={{-190.9,13.36},
          {-190,13.36},{-190,14},{-200,14},{-200,-106},{-207.1,-106}}, color={0,0,
          127}));
  connect(Charge_Control.umax, mMax_Charge) annotation (Line(points={{-194.9,-41.44},
          {-202,-41.44},{-202,-70},{-226,-70}}, color={0,0,127}));
  connect(Charge_Control.Setpoint, Power_Charge) annotation (Line(points={{-194.72,
          -45.76},{-208,-45.76},{-208,-32},{-232,-32}}, color={0,0,127}));
  connect(Charge_Control.umin, min_flow.y) annotation (Line(points={{-194.9,-52.64},
          {-200,-52.64},{-200,-106},{-207.1,-106}}, color={0,0,127}));
  connect(Debit_discharge_D1.y, D1_pump_top.Mflow) annotation (Line(points={{-188.9,
          87},{-188.9,82},{-188,82},{-188,62},{-169.25,62},{-169.25,60.6}},
        color={0,0,127}));
  connect(Debit_discharge_D2.y, D1_pump_bot.Mflow) annotation (Line(points={{-56.9,
          -87},{-56.9,-92},{-20,-92},{-20,-96},{-11.25,-96},{-11.25,-91.4}},
        color={0,0,127}));
  connect(Debit_Charge.y, C0_pump_bot.Mflow) annotation (Line(points={{50.2,-103},
          {46,-103},{46,-96},{48,-96},{48,-70},{39.8833,-70},{39.8833,-74.6}},
        color={0,0,127}));
  connect(Debit_Charge1.y, C0_pump_top.Mflow) annotation (Line(points={{-95.8,65},
          {-102,65},{-102,81.4},{-110.117,81.4}}, color={0,0,127}));
  connect(Pcharge_recalc.y, Charge_Control.Measure) annotation (Line(points={{-68.9,
          -61},{-68.9,-44},{-166,-44},{-166,-62},{-194.72,-62},{-194.72,-48.64}},
        color={0,0,127}));
  connect(PDischarge_recalc.y, Discharge_control.Measure) annotation (Line(
        points={{-106.9,-29},{-106.9,-12},{-202,-12},{-202,17.36},{-190.72,17.36}},
        color={0,0,127}));
  connect(Debit_Charge1.y, FlowCharge) annotation (Line(points={{-95.8,65},{-100,
          65},{-100,38},{94,38},{94,14},{108,14}}, color={0,0,127}));
  connect(Debit_discharge_D2.y, FlowDischarge) annotation (Line(points={{-56.9,-87},
          {-56.9,-92},{-20,-92},{-20,-62},{90,-62},{90,-10},{108,-10}}, color={0,
          0,127}));
  connect(Pcharge_recalc.y, Pcharge_real) annotation (Line(points={{-68.9,-61},{-68.9,
          -44},{92,-44},{92,-40},{106,-40}}, color={0,0,127}));
  connect(PDischarge_recalc.y, Pdischarge_real) annotation (Line(points={{-106.9,
          -29},{-106.9,-22},{-78,-22},{-78,-46},{92,-46},{92,-76},{110,-76}},
        color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-220,-120},
            {100,100}})), Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-220,-120},{100,100}})));
end Stratified_Control_Modif_old;
