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

char MESSAGE[16];
void initData() {
	int idx = 0;
	MESSAGE[idx++] = 'E';
	MESSAGE[idx++] = 'x';
	MESSAGE[idx++] = 'a';
	MESSAGE[idx++] = 'm';
	MESSAGE[idx++] = 'p';
	MESSAGE[idx++] = 'l';
	MESSAGE[idx++] = 'e';
	MESSAGE[idx++] = ' ';
	MESSAGE[idx++] = 'T';
	MESSAGE[idx++] = 'e';
	MESSAGE[idx++] = 'x';
	MESSAGE[idx++] = 't';
	MESSAGE[idx++] = '!';
	MESSAGE[idx++] = '!';
	MESSAGE[idx++] = '\n';
	MESSAGE[idx++] = '\0';
}

namespace {
	void uartSend(gpio::Uart &uart, int &pos) {
		uart.send(MESSAGE[pos]);
		if(pos == 16)
			pos = 0;
		else
			pos++;
	}
}

int main() {
	initData();
	gpio::LEDs leds;
	gpio::Uart uart;

	int idx = 0;

	while(1) {
		leds.roll();
		uartSend(uart, idx);
	}

	return 0;
}