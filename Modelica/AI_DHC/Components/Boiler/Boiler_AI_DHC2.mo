within AI_DHC.Components.Boiler;
record Boiler_AI_DHC2 "Other virtual gas-fired boiler for the project AI-DHC"
  extends AixLib.DataBase.Boiler.General.BoilerTwoPointBaseDataDefinition(
    name="Base_AIDHC",
    volume=Q_nom * 2.0*1e-6,
    pressureDrop=3240000000.0,
    Q_nom=6000000,
    Q_min=2000000,
     eta=[  0.3,0.9;
            0.6,0.925;
            0.8,0.94;
            0.9,0.945;
            1.0,0.94]);

    annotation (Documentation(revisions="",
          info=""));
end Boiler_AI_DHC2;
