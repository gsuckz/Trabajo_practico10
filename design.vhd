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

type estado is (reset,esp,recibiendo);
type codigo is (bit_1,bit_0,inicio,fin,err);
signal estado_actual,estado_sig                         : estado;
signal tiempo_pulso ,tiempo_pulso_sig           : std_logic_vector (6 downto 0);
signal duracion, duracion_prev                  : std_logic_vector (6 downto 0);
signal tipo_pulso,tipo_pulso_sig                : std_logic_vector (0 downto 0);
signal hab_med,hab_sipo                         : std_logic;
signal entrada                                  : codigo;
signal sipo_d,sipo_q                            : std_logic_vector (31 downto 0);
signal serial_data                              : std_logic;
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

duracion_anterior : ffd
    generic map (N=>7)
    port map (rst=>rst , hab=>hab_med , clk => clk , D => duracion, Q => duracion_prev);

SIPO : ffd
    generic map (N=>32)
    port map (rst=>rst , hab=>hab_sipo , clk => clk , D => sipo_d, Q => sipo_q);

sipo_d(30 downto 0) <= sipo_q(31 downto 1);





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
            hab_med <= '0'; --puede generar problemas por el tiempo de setup?
        end if;
        if infrarrojo'event then
            hab_med <= '1';
        end if;
    end process;

decod_entrada : process (clk)
    begin
            case duracion_prev is 
                when "0110000" => if unsigned(duracion) = 24 then
                                    entrada <= inicio;
                                end if;
                when "0000011" => if unsigned(duracion) = 3 then
                                    entrada <= bit_0;
                                elsif  unsigned(duracion) = 9 then
                                    entrada <= bit_1;
                                end if;                  
                when others => entrada <= err; 
            end case;                         
    end process; 
    
memoria_estado : process (clk)
    begin
        if rising_edge(clk) then
            estado_actual <= estado_sig;
        end if;
    end process;

estado_siguiente : process (clk)
    begin         
            case (estado_actual) is
                when esp => if entrada = inicio then
                                estado_sig <= recibiendo;
                            else
                                estado_sig <= esp;
                            end if;
                when recibiendo => if entrada /= bit_0 or entrada /= bit_1 or entrada /= inicio then
                                estado_sig <= esp;    
                            end if;     
                when others => estado_sig <= esp;
            end case;
    end process; 
    
    sipo_d(31) <= serial_data;
  
   -- ?? <= sipo_q;
        
    
leer_datos : process (clk)
    begin       
            if entrada = bit_1 then
                serial_data <= '1';
            else
                serial_data <= '0';
            end if;
        
        if estado_actual = recibiendo then
            hab_sipo <= hab_med;
        else 
            hab_sipo <= '0';    
        end if;
    end process; 
    
cmd <= sipo_q(15 downto 8);


dir <= sipo_q(7 downto 0);
        
        
                   
            




                    
                     
        
        










end solucion;



