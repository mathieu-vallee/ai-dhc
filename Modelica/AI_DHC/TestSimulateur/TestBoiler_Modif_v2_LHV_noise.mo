within AI_DHC.TestSimulateur;
model TestBoiler_Modif_v2_LHV_noise
  extends TestBoiler_Modif_v2;
  //  parameter String DC_file_in = "modelica://AI_DHC/Data/DC/Data_DC_no_default_G.txt";
  //  parameter String DC2_file_in = "modelica://AI_DHC/Data/DC/Data_DC_no_default_eta.txt";
  //parameter String DC_file_in = "modelica://AI_DHC/Data/DC/Data_DC_rampe_G_base.txt";
  //parameter String DC2_file_in = "modelica:///DistrictHeating/Projects/AI_DHC/Data/DC/Data_DC_creneau_eta_base.txt";
  parameter Real noise_samplePeriod = 600 "Periods for noise sampling in seconds";
  parameter Real noise_mu = 13.3 "LHV mean value in kWh/kg";
  parameter Real noise_sigma = 0.15 "LHV standard deviation in kWh/kg";
  Modelica.Units.SI.MassFlowRate massflow_fuel = boilerNoControl_modif.fuelPower/LHV_noise.y "mass flow rate of gas at inlet";
  Modelica.Blocks.Noise.NormalNoise LHV_noise(
    samplePeriod(displayUnit="min") = 600,
    mu=noise_mu*3600*1000,
    sigma=noise_sigma*3600*1000)
                "J/kg" annotation (Placement(transformation(extent={{100,20},{120,40}})));
  inner Modelica.Blocks.Noise.GlobalSeed globalSeed(useAutomaticSeed=true) annotation (Placement(transformation(extent={{100,50},{120,70}})));
  annotation (experiment(
      StopTime=2419200,
      Interval=300,
      Tolerance=1e-06,
      __Dymola_Algorithm="Radau"), __Dymola_experimentSetupOutput(events=false));
end TestBoiler_Modif_v2_LHV_noise;
