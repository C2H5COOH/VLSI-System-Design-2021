#DO NOT MODIFY THIS FILE
set ABVIP_INST_DIR /usr/cad/cadence/VIPCAT/cur/tools/abvip
set vip_dir $::env(vip_dir)

abvip -set_location $ABVIP_INST_DIR
set_visualize_auto_load_debugging_tables on
analyze -f $vip_dir/master_duv/jg.f -sv09
elaborate -top top -param top.axi_monitor_0.READONLY_INTERFACE 1\
-param top.axi_monitor_0.MAX_PENDING 1 -param top.axi_monitor_1.MAX_PENDING 1 

clock aclk
reset ~aresetn

assert -disable top.axi_monitor_0.genStableChks.genStableChksRDInf.master_ar_arprot_stable
assert -disable top.axi_monitor_0.genStableChks.genStableChksRDInf.genAXI4Full.master_ar_arlock_stable
assert -disable top.axi_monitor_0.genStableChks.genStableChksRDInf.genAXI4Full.master_ar_arcache_stable
assert -disable top.axi_monitor_0.genStableChks.genStableChksRDInf.genAXI4Full.master_ar_arqos_stable
assert -disable top.axi_monitor_0.genStableChks.genStableChksRDInf.genAXI4Full.master_ar_arregion_stable
assert -disable top.axi_monitor_0.genStableChks.genStableChksRDInf.genAXI4Full.master_ar_aruser_stable
assert -disable top.axi_monitor_0.genPropChksRDInf.genAXI4Full.master_ar_arcache_no_ra_wa_for_uncacheable
assert -disable top.axi_monitor_0.genPropChksRDInf.genAXI4Full.master_ar_araddr_wrap_aligned
assert -disable top.axi_monitor_0.genPropChksRDInf.genAXI4Full.master_ar_araddr_wrap_arlen
assert -disable top.axi_monitor_0.genPropChksRDInf.genAXI4Full.master_ar_araddr_fixed_arlen
assume -disable top.axi_monitor_0.genPropChksRDInf.genAXI4Full.genRdIlOff.slave_r_ar_rid_no_interleave
assume -disable top.axi_monitor_0.genStableChks.genStableChksRDInf.genAXI4Full.slave_r_ruser_stable

assert -disable top.axi_monitor_1.genStableChks.genStableChksRDInf.master_ar_arprot_stable
assert -disable top.axi_monitor_1.genStableChks.genStableChksRDInf.genAXI4Full.master_ar_arlock_stable
assert -disable top.axi_monitor_1.genStableChks.genStableChksRDInf.genAXI4Full.master_ar_arcache_stable
assert -disable top.axi_monitor_1.genStableChks.genStableChksRDInf.genAXI4Full.master_ar_arqos_stable
assert -disable top.axi_monitor_1.genStableChks.genStableChksRDInf.genAXI4Full.master_ar_arregion_stable
assert -disable top.axi_monitor_1.genStableChks.genStableChksRDInf.genAXI4Full.master_ar_aruser_stable
assert -disable top.axi_monitor_1.genPropChksRDInf.genAXI4Full.master_ar_arcache_no_ra_wa_for_uncacheable
assert -disable top.axi_monitor_1.genPropChksRDInf.genAXI4Full.master_ar_araddr_wrap_aligned
assert -disable top.axi_monitor_1.genPropChksRDInf.genAXI4Full.master_ar_araddr_wrap_arlen
assert -disable top.axi_monitor_1.genPropChksRDInf.genAXI4Full.master_ar_araddr_fixed_arlen
assert -disable top.axi_monitor_1.genStableChks.genStableChksWRInf.master_aw_awprot_stable
assert -disable top.axi_monitor_1.genStableChks.genStableChksWRInf.genAXI4Full.master_aw_awlock_stable
assert -disable top.axi_monitor_1.genStableChks.genStableChksWRInf.genAXI4Full.master_aw_awcache_stable
assert -disable top.axi_monitor_1.genStableChks.genStableChksWRInf.genAXI4Full.master_aw_awqos_stable
assert -disable top.axi_monitor_1.genStableChks.genStableChksWRInf.genAXI4Full.master_aw_awregion_stable
assert -disable top.axi_monitor_1.genStableChks.genStableChksWRInf.genAXI4Full.master_aw_awuser_stable
assert -disable top.axi_monitor_1.genStableChks.genStableChksWRInf.genAXI4Full.master_w_wuser_stable
assert -disable top.axi_monitor_1.genPropChksWRInf.genAXI4Full.master_aw_awcache_no_ra_wa_non_modifiable
assert -disable top.axi_monitor_1.genNoExChks.master_ar_arlock_no_excl_access_throttle_cnstr
assert -disable top.axi_monitor_1.genNoExChks.master_aw_awlock_no_excl_access_throttle_cnstr
assert -disable top.axi_monitor_1.genPropChksWRInf.genAXI4Full.master_aw_awaddr_wrap_aligned
assert -disable top.axi_monitor_1.genPropChksWRInf.genAXI4Full.master_aw_awaddr_wrap_awlen
assert -disable top.axi_monitor_1.genPropChksWRInf.genAXI4Full.master_aw_awaddr_fixed_awlen
assert -disable top.axi_monitor_1.genPropChksWRInf.master_w_aw_wlast_exact_len
assume -disable top.axi_monitor_1.genPropChksRDInf.genAXI4Full.genRdIlOff.slave_r_ar_rid_no_interleave
assume -disable top.axi_monitor_1.genStableChks.genStableChksRDInf.genAXI4Full.slave_r_ruser_stable
assume -disable top.axi_monitor_1.genStableChks.genStableChksWRInf.genAXI4Full.slave_b_buser_stable

#test load and store
assume {(rdata_m0[14:12] == 3'b010 || rdata_m0[14:12] == 3'b000) && (rdata_m0[6:0] == 7'b0000011 || rdata_m0[6:0] == 7'b0100011)}

prove -all

