library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ffd_pkg.all;

entity det_tiempo is
    generic (
        constant N : natural := 4);
    port(
        rst : in std_logic;
        pulso : in std_logic;
        hab : in std_logic;
        clk : in std_logic;
        med : out std_logic;
        tiempo : out std_logic_vector (N-1 downto 0));
end det_tiempo;

architecture solucion of det_tiempo is
    signal cuenta, cuenta_sig : std_logic_vector(N-1 downto 0);
    signal tiempoymed_sig, tiempoymed : std_logic_vector (N downto 0);
    
    subtype estado_t is std_logic_vector(0 downto 0);
    signal estado, estado_sig : estado_t;
    constant e_espera : estado_t := "0";
    constant e_cuenta : estado_t := "1";

begin     
    flipflopA : ffd
    generic map (N => N)
        port map(
            rst => rst,
            hab => hab,
            clk => clk,
            Q => cuenta,
            D => cuenta_sig
    );

    flipflop_sal : ffd
    generic map (N => N+1 ) 
        port map(
            rst => rst,
            hab => hab,
            clk => clk,
            Q   => tiempoymed,
            D   => tiempoymed_sig
    );
    
    tiempo <= tiempoymed (N-1 downto 0);
    med <= tiempoymed (N);

    salida :  process (all)
    begin
        case (estado) is
        when e_espera =>
            if pulso = '1' then
                tiempoymed_sig <= tiempoymed;
            else
                tiempoymed_sig(N-1 downto 0) <= tiempoymed(N-1 downto 0);
                tiempoymed_sig(N) <= '0';
            end if;
        when others => -- e_cuenta
            if pulso = '1' then
                tiempoymed_sig(N-1 downto 0) <= cuenta;
                tiempoymed_sig(N)  <= '1' ;
            else
                tiempoymed_sig <= tiempoymed;
            end if;
        end case;
    end process;


    contador :  process (all)
    begin
        case (estado) is 
        when e_cuenta =>
            if pulso = '0' and (unsigned(cuenta) /= 0)  then
                cuenta_sig <= std_logic_vector(unsigned (cuenta) + 1);
            else
                cuenta_sig <= cuenta;
            end if;
        when others => -- e_espera
            if pulso = '0' then 
                cuenta_sig <= (0=>'1', others => '0');
            else 
                cuenta_sig <= cuenta;
            end if;
        end case;
    end process;

    flipflop_estado: ffd
        generic map(N => 1)
        port map(
            rst => rst,
            hab => hab,
            clk => clk,
            Q   => estado,
            D   => estado_sig
    );

    pr_estado : process (all)
    begin
        case( estado ) is
        when e_espera =>
            if pulso = '0' then
                estado_sig <= e_cuenta;
            else
                estado_sig <= e_espera;
            end if;
        when e_cuenta =>
            if pulso = '0' then
                estado_sig <= e_cuenta;
            else
                estado_sig <= e_espera;
            end if;
        when others   =>
            estado_sig <= e_espera;
        end case ;
    end process;

end solucion;