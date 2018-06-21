#include "netxpto_20180418.h"
#include <stdio.h>

#include "binary_source_20180523.h"
#include "add_20180620.h"
#include "sink_20180118.h"
#include "bit_error_rate_20180424.h"
#include "fork_20180112.h"
#include "hamming_coder_20180608.h"
#include "hamming_decoder_20180608.h"


/* Hamming encoder decoder*/

int main(void) {
	// #####################################################################################################
	// ################################# System Input Parameters ###########################################
	// #####################################################################################################

	double probalilityOfZero_ErrorVector = 0.98;
	/* Variable used to implement errors to simulate a channel. The probability of error is p1 = 1 - p0. We 
	   define the probability of p0. */

	int hammingCode_ParityBits = 3;
	/* This variable defines the type of hamming code to use in the encoding and decoding blocks. 
		Valid values for this input:
		parity bits -> 2     Total bits:   3	Data bits:   1	Hamming Code (  3,   1)		Rate: 1  /  3
		parity bits -> 3     Total bits:   7	Data bits:   4	Hamming Code (  7,   4)		Rate: 4  /  7
		parity bits -> 4     Total bits:  15	Data bits:  11	Hamming Code ( 15,  11)		Rate: 11 / 15
		parity bits -> 5     Total bits:  31	Data bits:  26	Hamming Code ( 31,  26)		Rate: 26 / 31
		parity bits -> 6     Total bits:  63	Data bits:  57	Hamming Code ( 63,  57)		Rate: 57 / 63
		parity bits -> 7     Total bits: 127	Data bits: 120	Hamming Code (127, 120)		Rate: 120/127
		parity bits -> 8     Total bits: 255	Data bits: 247	Hamming Code (255, 247)		Rate: 247/255 */



	// #####################################################################################################
	// ########################### Signals Declaration and Inicialization ##################################
	// #####################################################################################################

	Binary S0{ "S0.sgn" };				/* Source Signal  */
	Binary S0_1{ "S0_1.sgn" };			/* Source Signal - Copy 1 */
	Binary S0_2{ "S0_2.sgn" };			/* Source Signal - Copy 2 */
	Binary S1{ "S1.sgn" };				/* Encoded Signal */
	Binary S2{ "S2.sgn" };				/* Decoded Signal */
	Binary S3{ "S3.sgn" };				/* Noise Signal */
	Binary S4{ "S4.sgn" };				/* Noise + Encoded Signal */
	Binary S5{ "S5.sgn" };				/* BER Signal */

	/* Save Signal */
	S0.setSaveSignal(true);
	S0_1.setSaveSignal(false);
	S0_2.setSaveSignal(false);
	S1.setSaveSignal(true);
	S2.setSaveSignal(true);
	S3.setSaveSignal(true);
	S4.setSaveSignal(true);
	S5.setSaveSignal(true);



	// #####################################################################################################
	// ########################### Blocks Declaration and Inicialization ###################################
	// #####################################################################################################

	/* Source Signal */
	BinarySource B1(vector <Signal*> {}, vector <Signal*> {&S0});
	B1.setBitPeriod(1);
	B1.setMode(Random);
	B1.setProbabilityOfZero(0.5);

	/* Use a predefine sequence that repeats cyclically */
	//B1.setMode(DeterministicCyclic);
	//B1.setBitStream("1010");

	B1.setNumberOfBits(10000);

	/* Create a copy of S0 Signal */
	Fork F1(vector <Signal*> {&S0}, vector <Signal*> {&S0_1, &S0_2});

	/* Hamming Encoder */
	HammingCoder H1(vector <Signal*> {&S0_1}, vector <Signal*> {&S1});
	H1.setParityBits(hammingCode_ParityBits);

	/* Noise Signal - Introduces errors with percentage of P1 = 1 - P0 */
	BinarySource B2(vector <Signal*> {}, vector <Signal*> {&S2});
	B2.setMode(Random);
	B2.setProbabilityOfZero(probalilityOfZero_ErrorVector);
	B2.setBitPeriod(1);

	/* Add Noise Signal to the Encoded Signal */
	Add A1(vector <Signal*> {&S1, &S2}, vector <Signal*> {&S3});
	
	/* Hamming Decoder */
	HammingDeCoder H2(vector <Signal*> {&S3}, vector <Signal*> {&S4});
	H2.setParityBits(hammingCode_ParityBits);
	
	/* BER */
	BitErrorRate B3(vector <Signal*> {&S0_2, &S4}, vector <Signal*> {&S5});

	/* Flush the output signal */
	Sink B4(vector <Signal*> {&S5}, vector <Signal*> {});
	B4.setDisplayNumberOfSamples(true);
	//B2.setNumberOfSamples(1000);



	// #####################################################################################################
	// ########################### System Declaration and Inicialization ###################################
	// #####################################################################################################

	System MainSystem{ vector <Block*> {&B1, &F1, &H1, &B2, &A1, &H2, &B3, &B4}};



	// #####################################################################################################
	// ########################### Run #####################################################################
	// #####################################################################################################

	MainSystem.run();

	return 0;
}
