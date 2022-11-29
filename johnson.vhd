library IEEE;
use IEEE.std_logic_1164.all;
use work.ffd_pkg.all;

entity johnson is
    generic (
        constant N:positive);
    port (
        rst   : in std_logic;
        hab   : in std_logic;
        clk   : in std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        Co    : out std_logic);
end johnson;

architecture solucion of johnson is
    signal Qo, Di : std_logic_vector (N-1 downto 0);

begin
    flipflop : ffd 
            generic map ( N => N)
            port map (rst => rst, 
                      hab => hab,
                      clk => clk, 
                      Q => Qo,
                      D => Di);
    Di(N-1 downto 1) <= Qo(N-2 downto 0);
    Di(0)<= not Qo(N-1);
    Q <= Qo;
    Co <= not(not Qo(N-1) or Qo(N-2));
end solucion;