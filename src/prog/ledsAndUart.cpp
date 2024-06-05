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

		void roll() {
			uint8_t pos = 0b10000000;
			while(pos != 0) {
				set(pos);
				pos >>= 1;
				utils::delay();
			}
		}

	private:
		static inline volatile unsigned int * const GPIO_LED_ADDR = reinterpret_cast<volatile unsigned int*>(0xbadf00d);
	};

	class Uart {
	public:
		void send(uint8_t keycode) {
			*GPIO_UART_ADDR = keycode;
		}

	private:
		static inline volatile unsigned int * const GPIO_UART_ADDR = reinterpret_cast<volatile unsigned int*>(0xcafebabe);
	};
}

namespace {
	const char MESSAGE[] = "Example Text!!\r\n";
	constexpr int MESSAGE_LEN = sizeof(MESSAGE);
}

int main() {
	gpio::LEDs leds;
	gpio::Uart uart;

	int charIdx = 0;

	while(1) {
		leds.roll();

		uart.send(MESSAGE[charIdx]);
		if(charIdx == MESSAGE_LEN-2) // don't print \0 character
			charIdx = 0;
		else
			charIdx++;
	}

	return 0;
}