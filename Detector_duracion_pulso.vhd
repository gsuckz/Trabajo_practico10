library IEEE;
use IEEE.std_logic_1164.all;
use work.det_tiempo_pkg.all;
use work.ffd_pkg.all;

--En tiempo se entrega la cantidad de ciclos desde el ultimo flanco, tipo='1' si fue ascendente, '0' sino.

entity tiempo_med is
    generic (constant N : natural := 1);
    port (
        rst     : in std_logic;
        pulso   : in std_logic;
        clk     : in std_logic;
        tiempo  : out std_logic_vector (N-1 downto 0);
        tipo    : out std_logic;
        med     : out std_logic);
        
end tiempo_med;

architecture solucion of tiempo_med is 
signal tipo_1, flanco  : std_logic;
signal tiempo_1         : std_logic_vector (N-1 downto 0);
begin 
    tipo_1      <=  tipo;
    tiempo_1    <= tiempo;

    tiempo_med : process (rst,clk)
        begin 
            if rst = '1'  then 
                tiempo  <= (others => '0'); 
                tiempo_t <= (others => '0'); 
                tipo    <= '0'';           
            elsif rising_edge(clk)   then
                tiempo_t <= std_logic_vector(unsigned(tiempo_t) + 1);  --es valido?
                 if flanco  then  
                    tiempo_t  <= std_logic_vector(1);
                    tipo      <= pulso;
                    tiempo    <= tiempo_t;
                end if;
            end if ;   
           
        end process;
                
    
                    
    

               

    flanco : process(rst,pulso,clk)
        begin   
            flanco <= '0';    
            if clk =0 or pulso'event and not(rst = '1') then
                flanco <= '1';
                end if;
        end process;
            

    med : process(tipo_1,clk)
        begin
            med<='0';
            if tipo_1'event or clk = '0' then
                med<='1';
            end if;
        end process;

end  solucion;




