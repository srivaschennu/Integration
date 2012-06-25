function testfreq(freqs)


freqs = freqs(:);
diffs = zeros(length(freqs),length(freqs));

for f = 1:length(freqs)
    diffs(f,:) = abs(freqs-freqs(f))';
    diffs(f,f) = Inf;
end

[minval,r] = min(diffs);
[minval,c] = min(minval);

fprintf('Minimum distance is %.1f between %.1f and %.1f.\n', minval, freqs(r(c)),freqs(c));