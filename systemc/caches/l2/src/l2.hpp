/* Copyright 2017 Columbia University, SLD Group */

#ifndef __L2_HPP__
#define __L2_HPP__

#include "cache_utils.hpp"
#include "l2_directives.hpp"
#include "l2_tags.hpp"
#include "l2_states.hpp"
#include "l2_hprots.hpp"
#include "l2_lines.hpp"
#include "l2_evict_ways.hpp"

class l2 : public sc_module
{

public:

    // Clock signal
    sc_in<bool> clk;

    // Reset signal
    sc_in<bool> rst;

    // Debug signals
    sc_out< sc_bv<ASSERT_WIDTH> >   asserts;
    sc_out< sc_bv<BOOKMARK_WIDTH> > bookmark;
    sc_out<uint32_t>                custom_dbg;

    sc_out<reqs_buf_t>          reqs_out[N_REQS];
    sc_out<bool>		evict_stall_out;
    sc_out<bool>		set_conflict_out;
    sc_out<l2_cpu_req_t>	cpu_req_conflict_out;
    sc_out<bool>		tag_hit_out;
    sc_out<l2_way_t>		way_hit_out;
    sc_out<bool>		empty_way_found_out;
    sc_out<l2_way_t>		empty_way_out;
    sc_out<l2_way_t>		way_evict_out;
    sc_out<bool>			reqs_hit_out;
    sc_out< sc_uint<REQS_BITS> >	reqs_hit_i_out;
    sc_out< sc_uint<REQS_BITS_P1> > reqs_cnt_out;   

    // Other signals
    sc_out<bool> flush_done;

    // Input ports
    nb_get_initiator<l2_cpu_req_t>	l2_cpu_req;
    nb_get_initiator<l2_fwd_in_t>	l2_fwd_in;
    nb_get_initiator<l2_rsp_in_t>	l2_rsp_in;
    nb_get_initiator<bool>		l2_flush;

    // Output ports
    put_initiator<l2_rd_rsp_t>	l2_rd_rsp;
    put_initiator<l2_inval_t>	l2_inval;
    nb_put_initiator<l2_req_out_t> l2_req_out;
    put_initiator<l2_rsp_out_t> l2_rsp_out;

    // Local memory (explicit, TODO: make implicit)
    l2_tags_t<tag_t, L2_LINES>		tags;
    l2_states_t<state_t, L2_LINES>	states;
    l2_hprots_t<hprot_t, L2_LINES>	hprots;
    l2_lines_t<line_t, L2_LINES>	lines;
    l2_evict_ways_t<l2_way_t, SETS>	evict_ways;

    // Local registers
    reqs_buf_t	 reqs[N_REQS];

    tag_t	 tag_buf[L2_WAYS];
    state_t	 state_buf[L2_WAYS];
    hprot_t	 hprot_buf[L2_WAYS];
    line_t	 lines_buf[L2_WAYS];
    l2_way_t	 evict_way;

    // Constructor
    SC_CTOR(l2)
    {
        // Cache controller process
	SC_CTHREAD(ctrl, clk.pos());
	reset_signal_is(rst, false);
	// set_stack_size(0x400000);

	// Assign clock and reset to put_get ports
	l2_cpu_req.clk_rst (clk, rst);
	l2_fwd_in.clk_rst (clk, rst);
	l2_rsp_in.clk_rst (clk, rst);
	l2_flush.clk_rst (clk, rst);
	l2_rd_rsp.clk_rst(clk, rst);
	l2_inval.clk_rst(clk, rst);
	l2_req_out.clk_rst(clk, rst);
	l2_rsp_out.clk_rst(clk, rst);

	// Flatten arrays
	FLATTEN_REGS;

	// Clock binding for memories
	tags.clk(this->clk);
	states.clk(this->clk);
	hprots.clk(this->clk);
	lines.clk(this->clk);
	evict_ways.clk(this->clk);
    }

    // Processes
    void ctrl(); // cache controller

    // Functions
    inline void reset_io();
    inline void reset_states();
    void tag_lookup(addr_breakdown_t addr_br, bool &tag_hit,
		    l2_way_t &way_hit, bool &empty_way_found,
		    l2_way_t &empty_way);
    void reqs_lookup(addr_breakdown_t addr_br, bool &reqs_hit, 
		     sc_uint<REQS_BITS> &reqs_hit_i);
    bool reqs_peek(set_t set, sc_uint<REQS_BITS> &reqs_i);
    void read_set(set_t set);
    void fill_reqs(cpu_msg_t cpu_msg, addr_breakdown_t addr_br, tag_t tag_estall, l2_way_t way_hit, hsize_t hsize,
		   unstable_state_t state, hprot_t hprot, 
		   invack_cnt_t invack_cnt, word_t word, 
		   line_t line, sc_uint<REQS_BITS> reqs_i);
    void get_cpu_req(l2_cpu_req_t &cpu_req);
    void get_rsp_in(l2_rsp_in_t &rsp_in);
    void get_flush();
    void send_req_out(coh_msg_t coh_msg, hprot_t hprot, 
		      addr_t line_addr, line_t lines);
    void send_rd_rsp(line_t lines);
    void send_inval(addr_t addr_inval);
    void put_reqs(set_t set, l2_way_t way, tag_t tag,
		  line_t lines, hprot_t hprot, state_t state);
    line_t make_line_of_addr(addr_t addr);

private:
    // debug
    sc_bv<ASSERT_WIDTH>   asserts_tmp;
    sc_bv<BOOKMARK_WIDTH> bookmark_tmp;
    uint64_t custom_dbg_tmp;
    bool evict_stall;
    bool set_conflict;
    l2_cpu_req_t	cpu_req_conflict;
    sc_uint<REQS_BITS_P1> reqs_cnt;
};


#endif /* __L2_HPP__ */
