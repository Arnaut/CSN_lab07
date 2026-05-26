-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : det_clic_dblclic_top.vhd
-- Auteur       : Etienne Messerli, le 05.05.2016
-- 
-- Description  : Detection d'un clic et double clic
--                Projet repris du labo Det_Clic_DblClic 2012
-- 
-- Utilise      : Labo SysLog2 2016
--| Modifications |------------------------------------------------------------
-- Ver   Date        Qui         Description
-- 1.0   20.11.2020  EMI   Ajout generique pour timer et maintien
-- 
-------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity det_clic_dblclic_top is
    generic (T1_g      : natural range 1 to 1023 := 4;
             T2_g      : natural range 1 to 1023 := 6;
             T_HOLD    : natural range 1 to 1023 := 2
             );
    port(clock_i       : in  std_logic;  --horloge systeme 1MHz
         nReset_i      : in  std_logic;  --reset asynchrone
         button_i      : in  std_logic;
         top_ms_i      : in  std_logic;
         clic_o        : out std_logic;
         dbl_clic_o    : out std_logic;
         clic_lg_o     : out std_logic;
         dbl_clic_lg_o : out std_logic
         );
end det_clic_dblclic_top;

architecture struct of det_clic_dblclic_top is

    -- Internal signal declarations
    signal reset_s                          : std_logic;
    signal start_s, trigger1_s, trigger2_s  : std_logic;
    signal btn_sync_s, clic_s, dbl_clic_s   : std_logic;
  
   -- Component declarations
    component timer
        generic (T1_g : natural range 1 to 1023 := 2;
            T2_g : natural range 1 to 1023 := 3);
        port (clock_i    : in  std_logic;
            reset_i    : in  std_logic;
            start_i    : in  std_logic;
            top_ms_i   : in  std_logic;
            trigger1_o : out std_logic;
            trigger2_o : out std_logic
            );
    end component;
    for all : timer use entity work.timer;

    component mss_clic_dblclic
        port (button_i  : in  std_logic;
            trigger1_i  : in  std_logic;
            trigger2_i  : in  std_logic;
            clock       : in  std_logic;
            reset       : in  std_logic;
            start_o     : out std_logic;
            clic_o      : out std_logic;
            dbl_clic_o  : out std_logic
            );
    end component;
    for all : mss_clic_dblclic use entity work.mss_clic_dblclic;

    component maintien
        generic (T_HOLD : natural range 1 to 1023 := 2);
        port (clock_i    : in  std_logic;
              reset_i    : in  std_logic;
              pulse_i    : in  std_logic;
              top_ms_i   : in  std_logic;
              p_hold_o   : out std_logic
              );
    end component;
    for all : maintien use entity work.maintien;


begin

    reset_s <= not (nReset_i);

    --process D_flip_flop pour btn_sync_s
    process(reset_s, clock_i)
    begin
        if reset_s = '1' then
            btn_sync_s <= '0';
        elsif rising_edge(clock_i) then
            btn_sync_s <= button_i;
        end if;
    end process;

    --intenciation du timer
	l_timer1 : timer 
	generic map(T1_g => T1_g, T2_g => T2_g)
	port map(clock_i   => clock_i,
            reset_i    => reset_s,
            start_i    => start_s,
            top_ms_i   => top_ms_i,
            trigger1_o => trigger1_s,
            trigger2_o => trigger2_s
            );
    
    --intenciation mss
    l_mss : mss_clic_dblclic
    port map(button_i   => btn_sync_s,
            trigger1_i  => trigger1_s,
            trigger2_i  => trigger2_s,
            clock       => clock_i,
            reset       => reset_s,
            start_o     => start_s,
            clic_o      => clic_s,
            dbl_clic_o  => dbl_clic_s
            );
    
    --intenciation maintien clic
    l_maintien_clic : maintien
    generic map(T_HOLD => T_HOLD)
    port map(clock_i     => clock_i,
              reset_i    => reset_s,
              pulse_i    => clic_s,
              top_ms_i   => top_ms_i,
              p_hold_o   => clic_lg_o
              );
    
    --intenciation maintien dbl_clic
    l_maintien_dbl_clic : maintien
    generic map(T_HOLD => T_HOLD)
    port map(clock_i     => clock_i,
              reset_i    => reset_s,
              pulse_i    => dbl_clic_s,
              top_ms_i   => top_ms_i,
              p_hold_o   => dbl_clic_lg_o
              );
    
    --gestion sortie restante
    clic_o        <= clic_s;
    dbl_clic_o    <= dbl_clic_s;
end struct;
