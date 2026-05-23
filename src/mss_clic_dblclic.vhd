-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : mss_clic_dblclic.vhd
-- Auteur       : Arnaut, le 22.05.2016
-- 
-- Description  : Implementation du MSS
-- 
-- Utilise      : Labo SysLog2 2016
--| Modifications |------------------------------------------------------------
-- Ver   Date      Qui            Description
-- 1.0	 22.05.26  Nadia; Arnaut  Implementation du MSS
-------------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;

entity mss_clic_dblclic is
    port (
        button_i, trigger1_i, trigger2_i : in  std_logic;
        clock, reset    : in  std_logic;
        start_o, clic_o, dbl_clic_o : out std_logic
    );
end mss_clic_dblclic;

architecture m_etat of mss_clic_dblclic is
    signal etat_present, etat_futur : std_logic_vector(3 downto 0);

    constant START : std_logic_vector(3 downto 0) := "0000";
    constant APPUI1 : std_logic_vector(3 downto 0) := "0001";
    constant MAINTIEN1 : std_logic_vector(3 downto 0) := "0010";
    constant PAUSE1 : std_logic_vector(3 downto 0) := "0011";
    constant PAUSE2 : std_logic_vector(3 downto 0) := "0100";
    constant CLC : std_logic_vector(3 downto 0) := "0101";
    constant APPUI2 : std_logic_vector(3 downto 0) := "0110";
    constant MAINTIEN2 : std_logic_vector(3 downto 0) := "0111";
    constant DBL   : std_logic_vector(3 downto 0) := "1000";

begin
    -- Processus combinatoire : calcul de l'état futur
    Fut: process (button_i, trigger1_i, trigger2_i, etat_present)
    begin
        etat_futur <= START; -- Valeur par défaut pour éviter les latches
        case etat_present is
            when START =>
                if button_i = '0' then
                    etat_futur <= START;
                else
                    etat_futur <= APPUI1;
                end if;
            when APPUI1 =>
                if button_i = '1' then
                    etat_futur <= MAINTIEN1;
                else
                    etat_futur <= PAUSE1;
                end if;
            when MAINTIEN1 =>
                if button_i = '0' then
                    etat_futur <= PAUSE1;
                elsif trigger2_i = '0' then
                    etat_futur <= MAINTIEN1;
                else
                    etat_futur <= START;
                end if;
            when PAUSE1 =>
                if button_i = '0' then
                    etat_futur <= PAUSE2;
                else
                    etat_futur <= APPUI2;
                end if;
            when PAUSE2 =>
                if button_i = '1' then
                    etat_futur <= APPUI2;
                elsif trigger1_i = '1' then
                    etat_futur <= CLC;
                else
                    etat_futur <= PAUSE2;
                end if;
            when CLC =>
                if button_i = '0' then
                    etat_futur <= START;
                else
                    etat_futur <= APPUI1;
                end if;
            when APPUI2 =>
                if button_i = '1' then
                    etat_futur <= MAINTIEN2;
                else
                    etat_futur <= DBL;
                end if;
            when MAINTIEN2 =>
                if button_i = '0' then
                    etat_futur <= DBL;
                elsif trigger2_i = '0' then
                    etat_futur <= MAINTIEN2;
                else
                    etat_futur <= CLC;
                end if;
            when DBL =>
                if button_i = '0' then
                    etat_futur <= START;
                else
                    etat_futur <= APPUI1;
                end if;
            when others =>
                etat_futur <= START;
        end case;
    end process;

    -- Processus de mémorisation
    Mem: process (clock, reset)
    begin
        if reset = '1' then
            etat_present <= START; -- Reset asynchrone prioritaire
        elsif rising_edge(clock) then
            etat_present <= etat_futur;
        end if;
    end process;

    -- Équation combinatoire de sortie
    start_o <= '1' when ((etat_present = APPUI1) or (etat_present = APPUI2) or (etat_present = PAUSE1)) else '0';
    clic_o <= '1' when (etat_present = CLC) else '0';
    dbl_clic_o <= '1' when (etat_present = DBL) else '0';
end m_etat;