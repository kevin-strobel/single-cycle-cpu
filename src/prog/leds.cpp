using uint8_t = unsigned char;
static_assert(sizeof(uint8_t) == 1);

namespace utils {
	[[gnu::always_inline]]
	inline void delay() {
		for(int i = 0; i < 1'000'000; i++)
			asm volatile("nop");
	}
}

namespace gpio {
	class LEDs {
	public:
		void set(uint8_t leds) {
			*GPIO_LED_ADDR = leds;
		}

		void alternate() {
			set(0b01010101);
			utils::delay();
			set(0b10101010);
			utils::delay();
		}

		void roll() {
			uint8_t pos = 0b10000000;
			while(pos != 0) {
				set(pos);
				pos >>= 1;
				utils::delay();
			}
		}

	private:
		// constexpr static unsigned int *GPIO_LED_ADDR = static_cast<unsigned int*>(0xbadf00d);
		static inline unsigned int * const GPIO_LED_ADDR = reinterpret_cast<unsigned int*>(0xbadf00d);
	};
}

int main() {
	gpio::LEDs leds;

	while(1) {
		leds.roll();
		leds.roll();
		leds.alternate();
		leds.alternate();
	}
	
	return 0;
}