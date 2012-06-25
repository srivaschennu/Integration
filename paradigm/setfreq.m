function setfreq(E1FC,E1FM,E2FC,E2FM,I1FF,I2FF)

load param.mat sweeptypes

for s = 1:length(sweeptypes)
    sweeptypes(s).E1FC = E1FC;
    sweeptypes(s).E1FM = E1FM;
    
    sweeptypes(s).E2FC = E2FC;
    sweeptypes(s).E2FM = E2FM;
    
    sweeptypes(s).I1FF = I1FF;
    sweeptypes(s).I2FF = I2FF;
end

save param.mat sweeptypes -append