library IEEE;
use IEEE.std_logic_1164.all;
use work.ffd_pkg.all;

entity det_flanco is
    port (
        rst          : in std_logic;
        D            : in std_logic;
        hab          : in std_logic;
        clk          : in std_logic;
        flanco       : out std_logic;
        flanco_asinc : out std_logic);
end det_flanco;

architecture solucion of det_flanco is
    signal Qo, Di : std_logic_vector(1 downto 0);
begin
    flipflop : ffd 
            generic map (N => 2)
            port map (rst => rst, 
                      hab => hab,
                      clk => clk,
                      Q => Qo,
                      D => Di);
Di(0) <= D;
Di(1) <= Qo(0);
flanco <= (Qo(0) and not Qo(1));
flanco_asinc <= ((D and not Qo(0)) or (Qo(0) and not Qo(1)) );
end solucion;