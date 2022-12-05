library IEEE;
use IEEE.std_logic_1164.all;
use std.env.finish;

entity receptor_control_remoto_tb is
end receptor_control_remoto_tb;

architecture tb of receptor_control_remoto_tb is
    component receptor_control_remoto is 
        port (
        rst         :    in std_logic;
        infrarrojo  :    in std_logic;
        hab         :    in std_logic;
        clk         :    in std_logic;
        valido      :    out std_logic;
        dir         :    out std_logic_vector (7 downto 0);
        cmd         :    out std_logic_vector (7 downto 0));
    end component;
    --Constantes
    constant T_clk      :    time := 187.5 us;
    constant pulso      :    time := 562.5 us;
    constant byte_dir     :    std_logic_vector (7 downto 0) := "00000000";
    constant byte_cmd     :    std_logic_vector (7 downto 0) := "11111111";

    --Señales
    signal rst_in, infrarrojo_in, hab_in, clk_in, valido_out : std_logic;
    signal dir_out, cmd_out : std_logic_vector (7 downto 0);

begin 

    DUT : receptor_control_remoto port map (
        rst         =>    rst_in, 
        infrarrojo  =>    infrarrojo_in, 
        hab         =>    hab_in, 
        clk         =>    clk_in,

        valido      =>    valido_out, 
        dir         =>    dir_out, 
        cmd         =>    cmd_out);
    
    clk_signal: process
    begin
        clk_in <= '0';
        wait for T_clk;
        clk_in <= '1';
        wait for T_clk;
    end process;

    data_signal : process
        variable pass : boolean := true;
    begin
        hab_in <= '1';
        rst_in <= '1';
        wait for 5 ms;
        if (valido_out /='0' or dir_out /= x"00" or cmd_out /= x"00") then
            report  "Estado luego de reset distinto al esperado"
            severity error;
            pass:= false;
        end if;
        rst_in <= '0';
        wait for 5 ms;
        infrarrojo_in <= '0';
        wait for 9000 us ;
        infrarrojo_in <= '1';
        wait for 4500 us;
        tx_dir : for k in 0 to 7 loop
            infrarrojo_in <= '0';
            wait for pulso;
            infrarrojo_in <= '1';
            wait for pulso;
            if byte_dir(k) = '1' then 
                wait for  2*pulso;
            end if;
        end loop;       
        tx_ndir : for k in 0 to 7 loop
            infrarrojo_in <= '0';
            wait for pulso;
            infrarrojo_in <= '1';
            wait for pulso;
            if byte_dir(k) = '0' then 
                wait for  2*pulso;
            end if;  
        end loop;    
        tx_cmd : for k in 0 to 7 loop
            infrarrojo_in <= '0';
            wait for pulso;
            infrarrojo_in <= '1';
            wait for pulso;
            if byte_cmd(k) = '1' then 
                wait for  2*pulso;
            end if;
        end loop;       
        tx_ncmd : for k in 0 to 7 loop
            infrarrojo_in <= '0';
            wait for pulso;
            infrarrojo_in <= '1';
            wait for pulso;
            if byte_cmd(k) = '0' then 
                wait for  2*pulso;
            end if;  
        end loop;
        infrarrojo_in <= '0';
        wait for pulso;
        infrarrojo_in <= '1';
        if (valido_out /= '1' or dir_out /= byte_dir or cmd_out /= byte_cmd) then
            report "Salida distinta a la esperada"
                   & lf & "    Esperaba valido '1', dir " & to_string(byte_dir) & ", cmd " & to_string(byte_cmd)
                   & lf & "    Obtenido valido " & std_logic'image(valido_out)
                   & ", dir " & to_string(dir_out) & ", cmd " & to_string(cmd_out)
            severity error;
            pass:=false;
        end if;
        if pass then
            report "[PASS]";
        else
            report "[FAIL]" severity failure;
        end if;
        finish;
    end process;
    
end tb;