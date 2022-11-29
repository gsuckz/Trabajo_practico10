library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ffd_pkg.all;

entity contador is
    generic (
        constant N:positive);
    port (
        rst   : in std_logic;
        D     : in std_logic_vector (N-1 downto 0);
        carga : in std_logic;
        hab   : in std_logic;
        clk   : in std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        Co    : out std_logic);
end contador;

architecture solucion of contador is

    signal Qo, Di : std_logic_vector (N-1 downto 0);

begin

    flipflop : ffd 
        generic map (N => N)
            port map  (rst => rst, 
                       hab => hab,
                       clk => clk, 
                       Q => Qo,
                       D => Di);

    lc : process (carga, D, Qo)
    begin
            if (carga = '1') then 
                Di <= D;
            else    
                Di <= std_logic_vector( unsigned (Qo)+1);
            end if;
    
    end process;

    Q <= Qo;
    Co <= '1' when   Qo = (N-1 downto 0 => '1') else '0';
    
end solucion;