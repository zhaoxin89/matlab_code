load model.mat
l = length (g_down_sample);
m_moving = M;
m_moving = [m_moving; zeros(l-length(M),1)];
for i = 0:l-length(M)
    m_moving = [0;m_moving];
    m_moving = m_moving(1:end-1,:);
    plot (m_moving);
    pause(0.01);
end