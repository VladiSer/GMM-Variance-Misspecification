function PlotMultipleVaryingStatsGraphs(caRecordings, varyingParameter, legendParameter, b_plotAdditionalStats, b_plotOneOverNLine)

b_plotEm = true;

if nargin < 4
    b_plotAdditionalStats = false;
    b_plotOneOverNLine = false;
end

kMeansFieldName = "sKmeansStatistics";
kMeansTitleString = "K-Means";

PlotStatisticsFigure(caRecordings, varyingParameter, legendParameter, b_plotAdditionalStats, b_plotOneOverNLine, kMeansFieldName, kMeansTitleString);

if b_plotEm
    emFieldNames = "sEmStatistics";
    emTitleString = "Expectation Maximization";
    PlotStatisticsFigure(caRecordings, varyingParameter, legendParameter, b_plotAdditionalStats, b_plotOneOverNLine, emFieldNames, emTitleString);
end

modelDim = caRecordings{1}.vModelDim(1);
for modelIndex = 1:modelDim
    modelKmeansString = sprintf("%s, model index %d", kMeansTitleString, modelIndex);
    PlotStatisticsFigureForModelIndex(caRecordings, varyingParameter, legendParameter, b_plotAdditionalStats, b_plotOneOverNLine, kMeansFieldName, modelKmeansString, modelIndex);
    
    if b_plotEm
        modelEmString =     sprintf("%s, model index %d", emTitleString, modelIndex);
        PlotStatisticsFigureForModelIndex(caRecordings, varyingParameter, legendParameter, b_plotAdditionalStats, b_plotOneOverNLine, emFieldNames, modelEmString, modelIndex);
    end
end
end
