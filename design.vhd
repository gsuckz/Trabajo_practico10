library IEEE;
use IEEE.std_logic_1164.all;


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
type estado is (reset,esp,rec);
type codigo is (bit_1,bit_0,inicio,fin);
signal actual,siguiente     : estado;
signal tiempo_pulso         : std_logic_vector (6 downto 0);
signal tipo_pulso           : std_logic;
 
begin 

datos : process (infrarrojo, clk)
variable contador : std_logic_vector (6 downto 0);
begin
    if infrarrojo'event then 
        tiempo_pulso (6 downto 0) <= contador;
        tipo_pulso <= not infrarrojo;
        contador (6 downto 0) <= (others => '0');
    end if;

    if rising_edge(clk) then 
        contador <= std_logic_vector( unsigned(contador) + 1);
        end if;
    end process;

    leer_entrada : process (tiempo_pulso)
    begin
    if not tipo_pulso and unsigned (tiempo_pulso) = 48 then
        wait;
        if tipo_pulso and unsigned (tiempo_pulso) = 24 then
            entrada <= inicio;
        end if;
    end if;
    if not tipo_pulso and unsigned (tiempo_pulso) = 6 then
        wait;
        if tipo_pulso then
            case (unsigned (tiempo_pulso) )  is
                when 6 =>   
                    entrada <= bit_0;
                when 24=>
                    entrada <= bit_1;
            end case;
        end if;
    end if;

end process;
            





siguiente : process (entrada,clk)
begin
    if rising_edge(clk) then
case (actual) is 

    when reset =>
    if entrada = inicio then
        siguiente <= rec;
    end if;

    
    when esp =>
    if entrada = inicio then
        siguiente <= rec;
    end if;

    when rec =>
    if entrada = inicio then
        siguiente <= rec;
    end if;  

    
    when others => siguiente <= reset;

    
    end case;

    end if;
end process;







end solucion;



