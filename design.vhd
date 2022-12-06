library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ffd_pkg.all;

entity receptor_control_remoto is 
    port (
        rst         :       in std_logic;
        infrarrojo  :       in std_logic;
        hab         :       in std_logic;
        clk         :       in std_logic;
        valido      :       out std_logic;
        dir         :       out std_logic_vector (7 downto 0);
        cmd         :       out std_logic_vector (7 downto 0));

end receptor_control_remoto;


architecture solucion of receptor_control_remoto is 

component ffd is
    generic(
        constant N : natural := 1);
    port(
        rst : in std_logic;
        D   : in std_logic_vector (N-1 downto 0);
        hab : in std_logic;
        clk : in std_logic;
        Q   : out std_logic_vector (N-1 downto 0));
end component;

type estado is (reset,esp,rec);

type codigo is (bit_1,bit_0,inicio,fin);
signal actual,siguiente                         : estado;
signal tiempo_pulso ,tiempo_pulso_sig           : std_logic_vector (6 downto 0);
signal duracion                                 : std_logic_vector (6 downto 0);
signal tipo_pulso,tipo_pulso_sig                : std_logic_vector (0 downto 0);
signal hab_med                                  : std_logic;
signal entrada                                  : codigo;
 
begin 
--conectamos elementos de memoria
contador_tiempo : ffd 
    generic map (N=>7)
    port map (rst=>rst , hab=>hab , clk => clk , D => tiempo_pulso_sig , Q => tiempo_pulso);

tipo_pulso_mem : ffd --es prescindible?
    generic map (N => 1)
    port map (rst=>rst , hab=>hab , clk => clk , D => tipo_pulso_sig, Q => tipo_pulso);

medicion_tiempo : ffd 
    generic map (N =>7)
    port map (rst=>rst , hab=>hab_med , clk => clk , D => tiempo_pulso, Q => duracion);


--describimos logica de estado siguiente
tiempo_pulso_sigp : process (infrarrojo,tiempo_pulso)  --La L.C que define a una señal se etiqueta como "nombreseñal"&lc
    begin
        if infrarrojo'event then
            tiempo_pulso_sig <= "0000001";
        elsif unsigned(tiempo_pulso) < 50 then
            tiempo_pulso_sig <= std_logic_vector(unsigned(tiempo_pulso) + 1);
        else 
            tiempo_pulso_sig <= (others => '0');     
        end if;
    end  process;

habilitacion_medicion : process (infrarrojo,clk)
    begin
        if rising_edge(clk) then
            hab_med <= '0';
        end if;
        if infrarrojo'event then
            hab_med <= '1';
        end if;
    end process;











end solucion;



