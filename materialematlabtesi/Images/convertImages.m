figs = openfig('rs.fig');
for K = 1 : length(figs)
   filename = 'rs.jpg';
   saveas(figs(K), filename);
end