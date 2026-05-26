-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : timer.vhd
-- Auteur       : Etienne Messerli, le 05.05.2016
-- 
-- Description  : Detection d'un clic et double clic
--                Projet repris du labo Det_Clic_DblClic 2012
-- 
-- Utilise      : Labo SysLog2 2016
--| Modifications |------------------------------------------------------------
-- Ver   Date      Qui            Description
-- 1.0   05.05.16  EMI            version initiale
-- 1.1   19.11.20  SMS            remplacement des constantes par des generiques
-- 2.0	 30.04.26  Nadia; Arnaut  Implementation description du timer
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    generic (
        T1_g : natural range 1 to 1023 := 2;
        T2_g : natural range 1 to 1023 := 3 );
    port (
        clock_i    : in  std_logic;
        reset_i    : in  std_logic;
        start_i    : in  std_logic;
        top_ms_i   : in  std_logic;
        trigger1_o : out std_logic;
        trigger2_o : out std_logic
        );
end timer;

architecture comport of timer is
  signal cpt_pres_s : unsigned(9 downto 0);
  signal cpt_fut_s : unsigned(9 downto 0);
  signal cpt_pres_p1_s : unsigned(10 downto 0);
  signal max_s : std_logic;

begin
  -- adder
  cpt_pres_p1_s <= ('0' & cpt_pres_s) + 1;
  max_s <= cpt_pres_p1_s(9);

  -- decodeur etats futur
  cpt_fut_s <=    (others =>'0')             when start_i = '1' else                                -- set
                  cpt_pres_p1_s(9 downto 0)  when ((max_s = '0') and (top_ms_i = '1')) else             -- Increment
                  cpt_pres_s;                                                                      -- Hold

  -- Registre
  process(clock_i, reset_i)
  begin
    if reset_i = '1' then
      cpt_pres_s <= (others =>'0');
    elsif Rising_Edge(clock_i) then
      cpt_pres_s <= cpt_fut_s;
    end if;
  end process;

  -- decodeur sortie
  trigger1_o <= '0' when cpt_pres_s < T1_g else
                '1';
  trigger2_o <= '0' when cpt_pres_s < T2_g else
                '1';

end comport;
