library IEEE;
use IEEE.std_logic_1164.all;
use work.det_tiempo_pkg.all;
use work.ffd_pkg.all;

--En tiempo se entrega la cantidad de ciclos desde el ultimo flanco, tipo='1' si fue descendente, '0' sino.

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
                tipo    <= '0'';           
            elsif clk'event then
                tiempo <= std_logic_vector(unsigned(tiempo_1) + 1);
                if flanco then  
                    tiempo  <= (others => '0');
                    tipo    <= pulso;
                end if;
            end if ;   
    
        end process;

    flanco : process(rst,pulso,clk)
        begin   
            flanco <= '0';    
            if pulso'event then
                flanco <= '1';
                end if;
        end process;
            

    med : process(tipo_1,clk)
        begin
            med<='0';
            if tipo_1'event then
                med<='1';
            end if;
        end process;

end  solucion;




