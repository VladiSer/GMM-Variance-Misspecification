function PlotStatisticsFigure(caRecordings, varyingParameter, legendParameter, b_plotAdditionalStats, b_plotOneOverNLine, wantedField, titleString)

f1 = figure("WindowStyle","docked","Name", titleString);
vAxes(1) = subplot(1, 3, 1);
hold(vAxes(1),'on')
vAxes(2) = subplot(1, 3, 2);
hold(vAxes(2),'on')
vAxes(3) = subplot(1, 3, 3);
vLegend = string(zeros(1, length(caRecordings)));
vColorMeanParameter = zeros(3, length(caRecordings));
vColorMinMaxParameter = zeros(3, length(caRecordings));
vColorVarParameter = zeros(3, length(caRecordings));
for recIndex = 1:length(caRecordings)
    vsExperimentResults = caRecordings{recIndex}.vsExperimentResults;
    sExperimentResults = ArrayOfStructsToStructOfArrays(vsExperimentResults);
    switch varyingParameter
        case E_Parameter.ObservationNumber
            vVaryingParameter = caRecordings{recIndex}.vObservationNumber;
            xLabelString = "N";
            sgTitleString = "Estimation stats vs number of observations";
            vAxes(1).XScale = 'log';
            vAxes(2).XScale = 'log';
            vAxes(2).YScale = 'log';
        case E_Parameter.Sigma
            vVaryingParameter = caRecordings{recIndex}.vSigma;
            vAxes(2).YScale = 'log';
            xLabelString = "$\sigma$";
            sgTitleString = "Estimation stats vs $\sigma$";
        case E_Parameter.ModelDim
            error("Not supported, but when the time comes need to filter out the irrelevant model data");
        otherwise
            error("Unsupported case");
    end

    switch legendParameter
        case E_Parameter.ObservationNumber
            parameterForLegend = caRecordings{recIndex}.vObservationNumber(1);
            vLegend(recIndex) = sprintf("N = %d", parameterForLegend);
        case E_Parameter.Sigma
            parameterForLegend = caRecordings{recIndex}.vSigma(1);
            vLegend(recIndex) = string(['$\sigma$',' = ',num2str(parameterForLegend)]);
        otherwise
            error("Unsupported case");
    end

    sLineVarParameter = plot(vAxes(1), vVaryingParameter, sExperimentResults.(wantedField).sMatchPercentage.mean);
    plot(vAxes(2), vVaryingParameter, sExperimentResults.(wantedField).sNormalizedL2Norm.mean);

    vColorMeanParameter(:, recIndex) = get(sLineVarParameter, 'Color');
    if b_plotAdditionalStats

        sLineMinMatches =  plot(vAxes(1), vVaryingParameter, sExperimentResults.(wantedField).sMatchPercentage.min, '--');
        plot(vAxes(2), vVaryingParameter, sExperimentResults.(wantedField).sNormalizedL2Norm.min, '--');

        vColorMinMaxParameter(:, recIndex) = get(sLineMinMatches, 'Color');

        plot(vAxes(1), vVaryingParameter, sExperimentResults.(wantedField).sMatchPercentage.max, '--', "Color", get(sLineMinMatches, 'Color'));
        plot(vAxes(2), vVaryingParameter, sExperimentResults.(wantedField).sNormalizedL2Norm.max, '--', "Color", get(sLineMinMatches, 'Color'));

        vTopVarMatches = min(sExperimentResults.(wantedField).sMatchPercentage.mean + sExperimentResults.(wantedField).sMatchPercentage.var.^(1/2)*3, 100);
        vBottomVarMatches = min(sExperimentResults.(wantedField).sMatchPercentage.mean - sExperimentResults.(wantedField).sMatchPercentage.var.^(1/2)*3, 100);
        vTopVarRmse = max(sExperimentResults.(wantedField).sNormalizedL2Norm.mean + sExperimentResults.(wantedField).sNormalizedL2Norm.var.^(1/2)*3, 0);
        vBottomVarRmse = max(sExperimentResults.(wantedField).sNormalizedL2Norm.mean - sExperimentResults.(wantedField).sNormalizedL2Norm.var.^(1/2)*3,0);

        sLineVarMatches = plot(vAxes(1), vVaryingParameter, vTopVarMatches, ":");
        plot(vAxes(2), vVaryingParameter, vTopVarRmse, ":");

        vColorVarParameter(:, recIndex) = get(sLineVarMatches, 'Color');

        plot(vAxes(1), vVaryingParameter, vBottomVarMatches, ":", "Color", get(sLineVarMatches, 'Color'));
        plot(vAxes(2), vVaryingParameter, vBottomVarRmse, ":", "Color", get(sLineVarMatches, 'Color'));
    end
end

if b_plotAdditionalStats
    vUsedLegend = string(zeros(length(caRecordings) * 3, 1));
else
    vUsedLegend = vLegend;
end

hold(vAxes(3),'on');
internalIdx = 1;
for dummyPlotIdx = 1:length(caRecordings)
    p(internalIdx) =  plot(vAxes(3), nan, nan, 'Color', vColorMeanParameter(:, dummyPlotIdx));
    internalIdx = internalIdx + 1;
    if b_plotAdditionalStats
        vUsedLegend(internalIdx - 1) = strcat("Mean estimation with ", vLegend(dummyPlotIdx));
        vUsedLegend(internalIdx) = strcat("Min and Max estimation with ", vLegend(dummyPlotIdx));
        vUsedLegend(internalIdx + 1) = strcat("$+-$3 estimation $\sigma$ with ", vLegend(dummyPlotIdx));
        p(internalIdx) =  plot(vAxes(3), nan, nan,'--', 'Color', vColorMinMaxParameter(:, dummyPlotIdx));
        internalIdx = internalIdx + 1;
        p(internalIdx) =  plot(vAxes(3),nan, nan,":", 'Color', vColorVarParameter(:, dummyPlotIdx));
        internalIdx = internalIdx + 1;
    end
end
if b_plotOneOverNLine
    sLineOneOverSqrt = plot(vAxes(2), vVaryingParameter, 1./vVaryingParameter, "-.");
    p(internalIdx) = plot(vAxes(3),nan, nan,"-.", 'Color', get(sLineOneOverSqrt, 'Color'));
    vUsedLegend(end+1) = "$\frac{1}{n}$ function";
end

hold(vAxes(3),'off');
vAxes(3).Visible = 'off';

hold(vAxes(1),'off');
hold(vAxes(2),'off');
vAxes(1).Position = [ 0.05    0.15    0.3   0.7];
vAxes(2).Position = [ 0.45    0.15    0.3   0.7];
sgtitle(f1, [titleString, " ", sgTitleString]);
xlabel(vAxes(1), xLabelString);
xlabel(vAxes(2), xLabelString);
ylabel(vAxes(1), "Assignment Percentage [%]");
ylabel(vAxes(2), "Normalized MSE");
grid(vAxes(1), "on");
vAxes(1).XMinorGrid = 'on';
vAxes(1).YMinorGrid = 'on';
grid(vAxes(2), "on");
vAxes(2).XMinorGrid = 'on';
vAxes(2).YMinorGrid = 'on';
legend(p, vUsedLegend, 'Interpreter', 'latex', 'Units', 'normalized', 'Position', [0.85, 0.75, 0.05, 0.1],"FontSize", 12);
if isempty(vAxes(1).Children) && isempty(vAxes(2).Children)
    close(f1);
end
end