altpll_rx_phaseshift_inst : altpll_rx_phaseshift PORT MAP (
		inclk0	 => inclk0_sig,
		phasecounterselect	 => phasecounterselect_sig,
		phasestep	 => phasestep_sig,
		phaseupdown	 => phaseupdown_sig,
		scanclk	 => scanclk_sig,
		c0	 => c0_sig,
		c1	 => c1_sig,
		c2	 => c2_sig,
		c3	 => c3_sig,
		locked	 => locked_sig,
		phasedone	 => phasedone_sig
	);
