function X = create_particles(center_pos, Npop_particles,r)

% X1 = randi(Npix_resolution(2), 1, Npop_particles);
% X2 = randi(Npix_resolution(1), 1, Npop_particles);
% X3 = zeros(2, Npop_particles);
X1 = randi(Npop_particles, 1, Npop_particles);
X2 = randi(Npop_particles, 1, Npop_particles);
for i = 1:Npop_particles
[X1(1,i),X2(1,i)]=cirrdnPJ(center_pos(1),center_pos(2),r);
end
X3 = zeros(2, Npop_particles);

X = [X1; X2; X3];
