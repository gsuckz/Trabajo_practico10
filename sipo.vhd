library IEEE;
use IEEE.std_logic_1164.all;
use work.ffd_pkg.all;

entity sipo is
    generic(
        N : natural := 4);
    port(
        rst     : in std_logic;
        entrada : in std_logic;
        hab     : in std_logic;
        clk     : in std_logic;
        Q       : out std_logic_vector (N-1 downto 0));
end sipo;

architecture solucion of sipo is
    signal Qo, Di : std_logic_vector (N-1 downto 0);

begin
    flipflop : ffd 
            generic map (N => N)
            port map (rst => rst, 
                      hab => hab,
                      clk => clk, 
                      Q => Qo,
                      D => Di);
    Di(n-1) <= entrada;
    Di(n-2 downto 0) <= Qo(n-1 downto 1);
    Q <= Qo;
end solucion;
