
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		_start
_start:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4 66                	in     $0x66,%al

f010000c <_start>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 00 11 00 	lgdtl  0x110018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100033:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100038:	e8 fd 00 00 00       	call   f010013a <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f0100046:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100049:	89 44 24 08          	mov    %eax,0x8(%esp)
f010004d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100050:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100054:	c7 04 24 20 1d 10 f0 	movl   $0xf0101d20,(%esp)
f010005b:	e8 f3 09 00 00       	call   f0100a53 <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 ae 09 00 00       	call   f0100a20 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 5f 20 10 f0 	movl   $0xf010205f,(%esp)
f0100079:	e8 d5 09 00 00       	call   f0100a53 <cprintf>
	va_end(ap);
}
f010007e:	c9                   	leave  
f010007f:	c3                   	ret    

f0100080 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100080:	55                   	push   %ebp
f0100081:	89 e5                	mov    %esp,%ebp
f0100083:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f0100086:	83 3d 40 03 11 f0 00 	cmpl   $0x0,0xf0110340
f010008d:	75 40                	jne    f01000cf <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f010008f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100092:	a3 40 03 11 f0       	mov    %eax,0xf0110340

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010009a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010009e:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a5:	c7 04 24 3a 1d 10 f0 	movl   $0xf0101d3a,(%esp)
f01000ac:	e8 a2 09 00 00       	call   f0100a53 <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 5d 09 00 00       	call   f0100a20 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 5f 20 10 f0 	movl   $0xf010205f,(%esp)
f01000ca:	e8 84 09 00 00       	call   f0100a53 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 05 07 00 00       	call   f01007e0 <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	53                   	push   %ebx
f01000e1:	83 ec 14             	sub    $0x14,%esp
f01000e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f01000e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000eb:	c7 04 24 52 1d 10 f0 	movl   $0xf0101d52,(%esp)
f01000f2:	e8 5c 09 00 00       	call   f0100a53 <cprintf>
	if (x > 0)
f01000f7:	85 db                	test   %ebx,%ebx
f01000f9:	7e 0d                	jle    f0100108 <test_backtrace+0x2b>
		test_backtrace(x-1);
f01000fb:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01000fe:	89 04 24             	mov    %eax,(%esp)
f0100101:	e8 d7 ff ff ff       	call   f01000dd <test_backtrace>
f0100106:	eb 1c                	jmp    f0100124 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f0100108:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010010f:	00 
f0100110:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100117:	00 
f0100118:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010011f:	e8 f4 07 00 00       	call   f0100918 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100124:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100128:	c7 04 24 6e 1d 10 f0 	movl   $0xf0101d6e,(%esp)
f010012f:	e8 1f 09 00 00       	call   f0100a53 <cprintf>
}
f0100134:	83 c4 14             	add    $0x14,%esp
f0100137:	5b                   	pop    %ebx
f0100138:	5d                   	pop    %ebp
f0100139:	c3                   	ret    

f010013a <i386_init>:

void
i386_init(void)
{
f010013a:	55                   	push   %ebp
f010013b:	89 e5                	mov    %esp,%ebp
f010013d:	83 ec 28             	sub    $0x28,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100140:	b8 a4 09 11 f0       	mov    $0xf01109a4,%eax
f0100145:	2d 24 03 11 f0       	sub    $0xf0110324,%eax
f010014a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010014e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100155:	00 
f0100156:	c7 04 24 24 03 11 f0 	movl   $0xf0110324,(%esp)
f010015d:	e8 e4 16 00 00       	call   f0101846 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100162:	e8 62 03 00 00       	call   f01004c9 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100167:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010016e:	00 
f010016f:	c7 04 24 89 1d 10 f0 	movl   $0xf0101d89,(%esp)
f0100176:	e8 d8 08 00 00       	call   f0100a53 <cprintf>

	unsigned int i = 0x00646c72;
f010017b:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
	cprintf( "H%x Wo%s\n", 57616, &i);
f0100182:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100185:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100189:	c7 44 24 04 10 e1 00 	movl   $0xe110,0x4(%esp)
f0100190:	00 
f0100191:	c7 04 24 a4 1d 10 f0 	movl   $0xf0101da4,(%esp)
f0100198:	e8 b6 08 00 00       	call   f0100a53 <cprintf>




	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f010019d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01001a4:	e8 34 ff ff ff       	call   f01000dd <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01001a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01001b0:	e8 2b 06 00 00       	call   f01007e0 <monitor>
f01001b5:	eb f2                	jmp    f01001a9 <i386_init+0x6f>
	...

f01001c0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba 84 00 00 00       	mov    $0x84,%edx
f01001c8:	ec                   	in     (%dx),%al
f01001c9:	ec                   	in     (%dx),%al
f01001ca:	ec                   	in     (%dx),%al
f01001cb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001cc:	5d                   	pop    %ebp
f01001cd:	c3                   	ret    

f01001ce <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001ce:	55                   	push   %ebp
f01001cf:	89 e5                	mov    %esp,%ebp
f01001d1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001d6:	ec                   	in     (%dx),%al
f01001d7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001de:	f6 c2 01             	test   $0x1,%dl
f01001e1:	74 09                	je     f01001ec <serial_proc_data+0x1e>
f01001e3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001e8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001e9:	0f b6 c0             	movzbl %al,%eax
}
f01001ec:	5d                   	pop    %ebp
f01001ed:	c3                   	ret    

f01001ee <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ee:	55                   	push   %ebp
f01001ef:	89 e5                	mov    %esp,%ebp
f01001f1:	57                   	push   %edi
f01001f2:	56                   	push   %esi
f01001f3:	53                   	push   %ebx
f01001f4:	83 ec 0c             	sub    $0xc,%esp
f01001f7:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001f9:	bb 84 05 11 f0       	mov    $0xf0110584,%ebx
f01001fe:	bf 80 03 11 f0       	mov    $0xf0110380,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100203:	eb 1e                	jmp    f0100223 <cons_intr+0x35>
		if (c == 0)
f0100205:	85 c0                	test   %eax,%eax
f0100207:	74 1a                	je     f0100223 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f0100209:	8b 13                	mov    (%ebx),%edx
f010020b:	88 04 17             	mov    %al,(%edi,%edx,1)
f010020e:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100211:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100216:	0f 94 c2             	sete   %dl
f0100219:	0f b6 d2             	movzbl %dl,%edx
f010021c:	83 ea 01             	sub    $0x1,%edx
f010021f:	21 d0                	and    %edx,%eax
f0100221:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100223:	ff d6                	call   *%esi
f0100225:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100228:	75 db                	jne    f0100205 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010022a:	83 c4 0c             	add    $0xc,%esp
f010022d:	5b                   	pop    %ebx
f010022e:	5e                   	pop    %esi
f010022f:	5f                   	pop    %edi
f0100230:	5d                   	pop    %ebp
f0100231:	c3                   	ret    

f0100232 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100232:	55                   	push   %ebp
f0100233:	89 e5                	mov    %esp,%ebp
f0100235:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100238:	b8 b9 05 10 f0       	mov    $0xf01005b9,%eax
f010023d:	e8 ac ff ff ff       	call   f01001ee <cons_intr>
}
f0100242:	c9                   	leave  
f0100243:	c3                   	ret    

f0100244 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100244:	55                   	push   %ebp
f0100245:	89 e5                	mov    %esp,%ebp
f0100247:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010024a:	83 3d 64 03 11 f0 00 	cmpl   $0x0,0xf0110364
f0100251:	74 0a                	je     f010025d <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100253:	b8 ce 01 10 f0       	mov    $0xf01001ce,%eax
f0100258:	e8 91 ff ff ff       	call   f01001ee <cons_intr>
}
f010025d:	c9                   	leave  
f010025e:	c3                   	ret    

f010025f <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010025f:	55                   	push   %ebp
f0100260:	89 e5                	mov    %esp,%ebp
f0100262:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100265:	e8 da ff ff ff       	call   f0100244 <serial_intr>
	kbd_intr();
f010026a:	e8 c3 ff ff ff       	call   f0100232 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010026f:	8b 15 80 05 11 f0    	mov    0xf0110580,%edx
f0100275:	b8 00 00 00 00       	mov    $0x0,%eax
f010027a:	3b 15 84 05 11 f0    	cmp    0xf0110584,%edx
f0100280:	74 21                	je     f01002a3 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100282:	0f b6 82 80 03 11 f0 	movzbl -0xfeefc80(%edx),%eax
f0100289:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010028c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100292:	0f 94 c1             	sete   %cl
f0100295:	0f b6 c9             	movzbl %cl,%ecx
f0100298:	83 e9 01             	sub    $0x1,%ecx
f010029b:	21 ca                	and    %ecx,%edx
f010029d:	89 15 80 05 11 f0    	mov    %edx,0xf0110580
		return c;
	}
	return 0;
}
f01002a3:	c9                   	leave  
f01002a4:	c3                   	ret    

f01002a5 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f01002a5:	55                   	push   %ebp
f01002a6:	89 e5                	mov    %esp,%ebp
f01002a8:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01002ab:	e8 af ff ff ff       	call   f010025f <cons_getc>
f01002b0:	85 c0                	test   %eax,%eax
f01002b2:	74 f7                	je     f01002ab <getchar+0x6>
		/* do nothing */;
	return c;
}
f01002b4:	c9                   	leave  
f01002b5:	c3                   	ret    

f01002b6 <iscons>:

int
iscons(int fdnum)
{
f01002b6:	55                   	push   %ebp
f01002b7:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01002b9:	b8 01 00 00 00       	mov    $0x1,%eax
f01002be:	5d                   	pop    %ebp
f01002bf:	c3                   	ret    

f01002c0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002c0:	55                   	push   %ebp
f01002c1:	89 e5                	mov    %esp,%ebp
f01002c3:	57                   	push   %edi
f01002c4:	56                   	push   %esi
f01002c5:	53                   	push   %ebx
f01002c6:	83 ec 2c             	sub    $0x2c,%esp
f01002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01002cc:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d1:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002d2:	a8 20                	test   $0x20,%al
f01002d4:	75 21                	jne    f01002f7 <cons_putc+0x37>
f01002d6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002db:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01002e0:	e8 db fe ff ff       	call   f01001c0 <delay>
f01002e5:	89 f2                	mov    %esi,%edx
f01002e7:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002e8:	a8 20                	test   $0x20,%al
f01002ea:	75 0b                	jne    f01002f7 <cons_putc+0x37>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002ec:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002ef:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002f5:	75 e9                	jne    f01002e0 <cons_putc+0x20>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f01002f7:	0f b6 7d e4          	movzbl -0x1c(%ebp),%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002fb:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100300:	89 f8                	mov    %edi,%eax
f0100302:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100303:	b2 79                	mov    $0x79,%dl
f0100305:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100306:	84 c0                	test   %al,%al
f0100308:	78 21                	js     f010032b <cons_putc+0x6b>
f010030a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010030f:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f0100314:	e8 a7 fe ff ff       	call   f01001c0 <delay>
f0100319:	89 f2                	mov    %esi,%edx
f010031b:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010031c:	84 c0                	test   %al,%al
f010031e:	78 0b                	js     f010032b <cons_putc+0x6b>
f0100320:	83 c3 01             	add    $0x1,%ebx
f0100323:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100329:	75 e9                	jne    f0100314 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100330:	89 f8                	mov    %edi,%eax
f0100332:	ee                   	out    %al,(%dx)
f0100333:	b2 7a                	mov    $0x7a,%dl
f0100335:	b8 0d 00 00 00       	mov    $0xd,%eax
f010033a:	ee                   	out    %al,(%dx)
f010033b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100340:	ee                   	out    %al,(%dx)
extern int ch_color;

static void
cga_putc(int c)
{
	c = c + (ch_color<<8);
f0100341:	a1 20 03 11 f0       	mov    0xf0110320,%eax
f0100346:	c1 e0 08             	shl    $0x8,%eax
f0100349:	03 45 e4             	add    -0x1c(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010034c:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f0100351:	75 03                	jne    f0100356 <cons_putc+0x96>
		c |= 0x0700;
f0100353:	80 cc 07             	or     $0x7,%ah

	switch (c & 0xff) {
f0100356:	0f b6 d0             	movzbl %al,%edx
f0100359:	83 fa 09             	cmp    $0x9,%edx
f010035c:	0f 84 80 00 00 00    	je     f01003e2 <cons_putc+0x122>
f0100362:	83 fa 09             	cmp    $0x9,%edx
f0100365:	7f 0b                	jg     f0100372 <cons_putc+0xb2>
f0100367:	83 fa 08             	cmp    $0x8,%edx
f010036a:	0f 85 a6 00 00 00    	jne    f0100416 <cons_putc+0x156>
f0100370:	eb 18                	jmp    f010038a <cons_putc+0xca>
f0100372:	83 fa 0a             	cmp    $0xa,%edx
f0100375:	8d 76 00             	lea    0x0(%esi),%esi
f0100378:	74 3e                	je     f01003b8 <cons_putc+0xf8>
f010037a:	83 fa 0d             	cmp    $0xd,%edx
f010037d:	8d 76 00             	lea    0x0(%esi),%esi
f0100380:	0f 85 90 00 00 00    	jne    f0100416 <cons_putc+0x156>
f0100386:	66 90                	xchg   %ax,%ax
f0100388:	eb 36                	jmp    f01003c0 <cons_putc+0x100>
	case '\b':
		if (crt_pos > 0) {
f010038a:	0f b7 15 70 03 11 f0 	movzwl 0xf0110370,%edx
f0100391:	66 85 d2             	test   %dx,%dx
f0100394:	0f 84 e7 00 00 00    	je     f0100481 <cons_putc+0x1c1>
			crt_pos--;
f010039a:	83 ea 01             	sub    $0x1,%edx
f010039d:	66 89 15 70 03 11 f0 	mov    %dx,0xf0110370
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003a4:	0f b7 d2             	movzwl %dx,%edx
f01003a7:	b0 00                	mov    $0x0,%al
f01003a9:	83 c8 20             	or     $0x20,%eax
f01003ac:	8b 0d 6c 03 11 f0    	mov    0xf011036c,%ecx
f01003b2:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f01003b6:	eb 7c                	jmp    f0100434 <cons_putc+0x174>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003b8:	66 83 05 70 03 11 f0 	addw   $0x50,0xf0110370
f01003bf:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003c0:	0f b7 05 70 03 11 f0 	movzwl 0xf0110370,%eax
f01003c7:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003cd:	c1 e8 10             	shr    $0x10,%eax
f01003d0:	66 c1 e8 06          	shr    $0x6,%ax
f01003d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003d7:	c1 e0 04             	shl    $0x4,%eax
f01003da:	66 a3 70 03 11 f0    	mov    %ax,0xf0110370
f01003e0:	eb 52                	jmp    f0100434 <cons_putc+0x174>
		break;
	case '\t':
		cons_putc(' ');
f01003e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e7:	e8 d4 fe ff ff       	call   f01002c0 <cons_putc>
		cons_putc(' ');
f01003ec:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f1:	e8 ca fe ff ff       	call   f01002c0 <cons_putc>
		cons_putc(' ');
f01003f6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fb:	e8 c0 fe ff ff       	call   f01002c0 <cons_putc>
		cons_putc(' ');
f0100400:	b8 20 00 00 00       	mov    $0x20,%eax
f0100405:	e8 b6 fe ff ff       	call   f01002c0 <cons_putc>
		cons_putc(' ');
f010040a:	b8 20 00 00 00       	mov    $0x20,%eax
f010040f:	e8 ac fe ff ff       	call   f01002c0 <cons_putc>
f0100414:	eb 1e                	jmp    f0100434 <cons_putc+0x174>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100416:	0f b7 15 70 03 11 f0 	movzwl 0xf0110370,%edx
f010041d:	0f b7 da             	movzwl %dx,%ebx
f0100420:	8b 0d 6c 03 11 f0    	mov    0xf011036c,%ecx
f0100426:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010042a:	83 c2 01             	add    $0x1,%edx
f010042d:	66 89 15 70 03 11 f0 	mov    %dx,0xf0110370
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100434:	66 81 3d 70 03 11 f0 	cmpw   $0x7cf,0xf0110370
f010043b:	cf 07 
f010043d:	76 42                	jbe    f0100481 <cons_putc+0x1c1>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010043f:	a1 6c 03 11 f0       	mov    0xf011036c,%eax
f0100444:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010044b:	00 
f010044c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100452:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100456:	89 04 24             	mov    %eax,(%esp)
f0100459:	e8 47 14 00 00       	call   f01018a5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010045e:	8b 15 6c 03 11 f0    	mov    0xf011036c,%edx
f0100464:	b8 80 07 00 00       	mov    $0x780,%eax
f0100469:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010046f:	83 c0 01             	add    $0x1,%eax
f0100472:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100477:	75 f0                	jne    f0100469 <cons_putc+0x1a9>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100479:	66 83 2d 70 03 11 f0 	subw   $0x50,0xf0110370
f0100480:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100481:	8b 0d 68 03 11 f0    	mov    0xf0110368,%ecx
f0100487:	89 cb                	mov    %ecx,%ebx
f0100489:	b8 0e 00 00 00       	mov    $0xe,%eax
f010048e:	89 ca                	mov    %ecx,%edx
f0100490:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100491:	0f b7 35 70 03 11 f0 	movzwl 0xf0110370,%esi
f0100498:	83 c1 01             	add    $0x1,%ecx
f010049b:	89 f0                	mov    %esi,%eax
f010049d:	66 c1 e8 08          	shr    $0x8,%ax
f01004a1:	89 ca                	mov    %ecx,%edx
f01004a3:	ee                   	out    %al,(%dx)
f01004a4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004a9:	89 da                	mov    %ebx,%edx
f01004ab:	ee                   	out    %al,(%dx)
f01004ac:	89 f0                	mov    %esi,%eax
f01004ae:	89 ca                	mov    %ecx,%edx
f01004b0:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004b1:	83 c4 2c             	add    $0x2c,%esp
f01004b4:	5b                   	pop    %ebx
f01004b5:	5e                   	pop    %esi
f01004b6:	5f                   	pop    %edi
f01004b7:	5d                   	pop    %ebp
f01004b8:	c3                   	ret    

f01004b9 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01004b9:	55                   	push   %ebp
f01004ba:	89 e5                	mov    %esp,%ebp
f01004bc:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01004bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01004c2:	e8 f9 fd ff ff       	call   f01002c0 <cons_putc>
}
f01004c7:	c9                   	leave  
f01004c8:	c3                   	ret    

f01004c9 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004c9:	55                   	push   %ebp
f01004ca:	89 e5                	mov    %esp,%ebp
f01004cc:	57                   	push   %edi
f01004cd:	56                   	push   %esi
f01004ce:	53                   	push   %ebx
f01004cf:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004d2:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01004d7:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01004da:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01004df:	0f b7 00             	movzwl (%eax),%eax
f01004e2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01004e6:	74 11                	je     f01004f9 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01004e8:	c7 05 68 03 11 f0 b4 	movl   $0x3b4,0xf0110368
f01004ef:	03 00 00 
f01004f2:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01004f7:	eb 16                	jmp    f010050f <cons_init+0x46>
	} else {
		*cp = was;
f01004f9:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100500:	c7 05 68 03 11 f0 d4 	movl   $0x3d4,0xf0110368
f0100507:	03 00 00 
f010050a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010050f:	8b 0d 68 03 11 f0    	mov    0xf0110368,%ecx
f0100515:	89 cb                	mov    %ecx,%ebx
f0100517:	b8 0e 00 00 00       	mov    $0xe,%eax
f010051c:	89 ca                	mov    %ecx,%edx
f010051e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010051f:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100522:	89 ca                	mov    %ecx,%edx
f0100524:	ec                   	in     (%dx),%al
f0100525:	0f b6 f8             	movzbl %al,%edi
f0100528:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010052b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100530:	89 da                	mov    %ebx,%edx
f0100532:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100533:	89 ca                	mov    %ecx,%edx
f0100535:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100536:	89 35 6c 03 11 f0    	mov    %esi,0xf011036c
	crt_pos = pos;
f010053c:	0f b6 c8             	movzbl %al,%ecx
f010053f:	09 cf                	or     %ecx,%edi
f0100541:	66 89 3d 70 03 11 f0 	mov    %di,0xf0110370
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100548:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010054d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100552:	89 da                	mov    %ebx,%edx
f0100554:	ee                   	out    %al,(%dx)
f0100555:	b2 fb                	mov    $0xfb,%dl
f0100557:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010055c:	ee                   	out    %al,(%dx)
f010055d:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100562:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100567:	89 ca                	mov    %ecx,%edx
f0100569:	ee                   	out    %al,(%dx)
f010056a:	b2 f9                	mov    $0xf9,%dl
f010056c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100571:	ee                   	out    %al,(%dx)
f0100572:	b2 fb                	mov    $0xfb,%dl
f0100574:	b8 03 00 00 00       	mov    $0x3,%eax
f0100579:	ee                   	out    %al,(%dx)
f010057a:	b2 fc                	mov    $0xfc,%dl
f010057c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100581:	ee                   	out    %al,(%dx)
f0100582:	b2 f9                	mov    $0xf9,%dl
f0100584:	b8 01 00 00 00       	mov    $0x1,%eax
f0100589:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010058a:	b2 fd                	mov    $0xfd,%dl
f010058c:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010058d:	3c ff                	cmp    $0xff,%al
f010058f:	0f 95 c0             	setne  %al
f0100592:	0f b6 f0             	movzbl %al,%esi
f0100595:	89 35 64 03 11 f0    	mov    %esi,0xf0110364
f010059b:	89 da                	mov    %ebx,%edx
f010059d:	ec                   	in     (%dx),%al
f010059e:	89 ca                	mov    %ecx,%edx
f01005a0:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005a1:	85 f6                	test   %esi,%esi
f01005a3:	75 0c                	jne    f01005b1 <cons_init+0xe8>
		cprintf("Serial port does not exist!\n");
f01005a5:	c7 04 24 ae 1d 10 f0 	movl   $0xf0101dae,(%esp)
f01005ac:	e8 a2 04 00 00       	call   f0100a53 <cprintf>
}
f01005b1:	83 c4 1c             	add    $0x1c,%esp
f01005b4:	5b                   	pop    %ebx
f01005b5:	5e                   	pop    %esi
f01005b6:	5f                   	pop    %edi
f01005b7:	5d                   	pop    %ebp
f01005b8:	c3                   	ret    

f01005b9 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01005b9:	55                   	push   %ebp
f01005ba:	89 e5                	mov    %esp,%ebp
f01005bc:	53                   	push   %ebx
f01005bd:	83 ec 14             	sub    $0x14,%esp
f01005c0:	ba 64 00 00 00       	mov    $0x64,%edx
f01005c5:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01005c6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005cb:	a8 01                	test   $0x1,%al
f01005cd:	0f 84 d9 00 00 00    	je     f01006ac <kbd_proc_data+0xf3>
f01005d3:	b2 60                	mov    $0x60,%dl
f01005d5:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01005d6:	3c e0                	cmp    $0xe0,%al
f01005d8:	75 11                	jne    f01005eb <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01005da:	83 0d 60 03 11 f0 40 	orl    $0x40,0xf0110360
f01005e1:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01005e6:	e9 c1 00 00 00       	jmp    f01006ac <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f01005eb:	84 c0                	test   %al,%al
f01005ed:	79 32                	jns    f0100621 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01005ef:	8b 15 60 03 11 f0    	mov    0xf0110360,%edx
f01005f5:	f6 c2 40             	test   $0x40,%dl
f01005f8:	75 03                	jne    f01005fd <kbd_proc_data+0x44>
f01005fa:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01005fd:	0f b6 c0             	movzbl %al,%eax
f0100600:	0f b6 80 e0 1d 10 f0 	movzbl -0xfefe220(%eax),%eax
f0100607:	83 c8 40             	or     $0x40,%eax
f010060a:	0f b6 c0             	movzbl %al,%eax
f010060d:	f7 d0                	not    %eax
f010060f:	21 c2                	and    %eax,%edx
f0100611:	89 15 60 03 11 f0    	mov    %edx,0xf0110360
f0100617:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010061c:	e9 8b 00 00 00       	jmp    f01006ac <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100621:	8b 15 60 03 11 f0    	mov    0xf0110360,%edx
f0100627:	f6 c2 40             	test   $0x40,%dl
f010062a:	74 0c                	je     f0100638 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010062c:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f010062f:	83 e2 bf             	and    $0xffffffbf,%edx
f0100632:	89 15 60 03 11 f0    	mov    %edx,0xf0110360
	}

	shift |= shiftcode[data];
f0100638:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010063b:	0f b6 90 e0 1d 10 f0 	movzbl -0xfefe220(%eax),%edx
f0100642:	0b 15 60 03 11 f0    	or     0xf0110360,%edx
f0100648:	0f b6 88 e0 1e 10 f0 	movzbl -0xfefe120(%eax),%ecx
f010064f:	31 ca                	xor    %ecx,%edx
f0100651:	89 15 60 03 11 f0    	mov    %edx,0xf0110360

	c = charcode[shift & (CTL | SHIFT)][data];
f0100657:	89 d1                	mov    %edx,%ecx
f0100659:	83 e1 03             	and    $0x3,%ecx
f010065c:	8b 0c 8d e0 1f 10 f0 	mov    -0xfefe020(,%ecx,4),%ecx
f0100663:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100667:	f6 c2 08             	test   $0x8,%dl
f010066a:	74 1a                	je     f0100686 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010066c:	89 d9                	mov    %ebx,%ecx
f010066e:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100671:	83 f8 19             	cmp    $0x19,%eax
f0100674:	77 05                	ja     f010067b <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100676:	83 eb 20             	sub    $0x20,%ebx
f0100679:	eb 0b                	jmp    f0100686 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010067b:	83 e9 41             	sub    $0x41,%ecx
f010067e:	83 f9 19             	cmp    $0x19,%ecx
f0100681:	77 03                	ja     f0100686 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100683:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100686:	f7 d2                	not    %edx
f0100688:	f6 c2 06             	test   $0x6,%dl
f010068b:	75 1f                	jne    f01006ac <kbd_proc_data+0xf3>
f010068d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100693:	75 17                	jne    f01006ac <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100695:	c7 04 24 cb 1d 10 f0 	movl   $0xf0101dcb,(%esp)
f010069c:	e8 b2 03 00 00       	call   f0100a53 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a1:	ba 92 00 00 00       	mov    $0x92,%edx
f01006a6:	b8 03 00 00 00       	mov    $0x3,%eax
f01006ab:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01006ac:	89 d8                	mov    %ebx,%eax
f01006ae:	83 c4 14             	add    $0x14,%esp
f01006b1:	5b                   	pop    %ebx
f01006b2:	5d                   	pop    %ebp
f01006b3:	c3                   	ret    
	...

f01006c0 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006c0:	55                   	push   %ebp
f01006c1:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006c3:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006c6:	5d                   	pop    %ebp
f01006c7:	c3                   	ret    

f01006c8 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006c8:	55                   	push   %ebp
f01006c9:	89 e5                	mov    %esp,%ebp
f01006cb:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006ce:	c7 04 24 f0 1f 10 f0 	movl   $0xf0101ff0,(%esp)
f01006d5:	e8 79 03 00 00       	call   f0100a53 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f01006da:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006e1:	00 
f01006e2:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006e9:	f0 
f01006ea:	c7 04 24 bc 20 10 f0 	movl   $0xf01020bc,(%esp)
f01006f1:	e8 5d 03 00 00       	call   f0100a53 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006f6:	c7 44 24 08 15 1d 10 	movl   $0x101d15,0x8(%esp)
f01006fd:	00 
f01006fe:	c7 44 24 04 15 1d 10 	movl   $0xf0101d15,0x4(%esp)
f0100705:	f0 
f0100706:	c7 04 24 e0 20 10 f0 	movl   $0xf01020e0,(%esp)
f010070d:	e8 41 03 00 00       	call   f0100a53 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100712:	c7 44 24 08 24 03 11 	movl   $0x110324,0x8(%esp)
f0100719:	00 
f010071a:	c7 44 24 04 24 03 11 	movl   $0xf0110324,0x4(%esp)
f0100721:	f0 
f0100722:	c7 04 24 04 21 10 f0 	movl   $0xf0102104,(%esp)
f0100729:	e8 25 03 00 00       	call   f0100a53 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010072e:	c7 44 24 08 a4 09 11 	movl   $0x1109a4,0x8(%esp)
f0100735:	00 
f0100736:	c7 44 24 04 a4 09 11 	movl   $0xf01109a4,0x4(%esp)
f010073d:	f0 
f010073e:	c7 04 24 28 21 10 f0 	movl   $0xf0102128,(%esp)
f0100745:	e8 09 03 00 00       	call   f0100a53 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010074a:	b8 a3 0d 11 f0       	mov    $0xf0110da3,%eax
f010074f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100754:	89 c2                	mov    %eax,%edx
f0100756:	c1 fa 1f             	sar    $0x1f,%edx
f0100759:	c1 ea 16             	shr    $0x16,%edx
f010075c:	8d 04 02             	lea    (%edx,%eax,1),%eax
f010075f:	c1 f8 0a             	sar    $0xa,%eax
f0100762:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100766:	c7 04 24 4c 21 10 f0 	movl   $0xf010214c,(%esp)
f010076d:	e8 e1 02 00 00       	call   f0100a53 <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f0100772:	b8 00 00 00 00       	mov    $0x0,%eax
f0100777:	c9                   	leave  
f0100778:	c3                   	ret    

f0100779 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100779:	55                   	push   %ebp
f010077a:	89 e5                	mov    %esp,%ebp
f010077c:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010077f:	a1 64 22 10 f0       	mov    0xf0102264,%eax
f0100784:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100788:	a1 60 22 10 f0       	mov    0xf0102260,%eax
f010078d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100791:	c7 04 24 09 20 10 f0 	movl   $0xf0102009,(%esp)
f0100798:	e8 b6 02 00 00       	call   f0100a53 <cprintf>
f010079d:	a1 70 22 10 f0       	mov    0xf0102270,%eax
f01007a2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007a6:	a1 6c 22 10 f0       	mov    0xf010226c,%eax
f01007ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007af:	c7 04 24 09 20 10 f0 	movl   $0xf0102009,(%esp)
f01007b6:	e8 98 02 00 00       	call   f0100a53 <cprintf>
f01007bb:	a1 7c 22 10 f0       	mov    0xf010227c,%eax
f01007c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007c4:	a1 78 22 10 f0       	mov    0xf0102278,%eax
f01007c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007cd:	c7 04 24 09 20 10 f0 	movl   $0xf0102009,(%esp)
f01007d4:	e8 7a 02 00 00       	call   f0100a53 <cprintf>
	return 0;
}
f01007d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01007de:	c9                   	leave  
f01007df:	c3                   	ret    

f01007e0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007e0:	55                   	push   %ebp
f01007e1:	89 e5                	mov    %esp,%ebp
f01007e3:	57                   	push   %edi
f01007e4:	56                   	push   %esi
f01007e5:	53                   	push   %ebx
f01007e6:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("%CredWelcome %Cwhtto %Cgrnthe %CorgJOS %Cgrykernel %Cpurmonitor!\n");
f01007e9:	c7 04 24 78 21 10 f0 	movl   $0xf0102178,(%esp)
f01007f0:	e8 5e 02 00 00       	call   f0100a53 <cprintf>
	cprintf("%CcynType %Cylw'help' %C142for a %C201list %C088of %Cwhtcommands.\n");
f01007f5:	c7 04 24 bc 21 10 f0 	movl   $0xf01021bc,(%esp)
f01007fc:	e8 52 02 00 00       	call   f0100a53 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100801:	c7 04 24 12 20 10 f0 	movl   $0xf0102012,(%esp)
f0100808:	e8 b3 0d 00 00       	call   f01015c0 <readline>
f010080d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010080f:	85 c0                	test   %eax,%eax
f0100811:	74 ee                	je     f0100801 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100813:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f010081a:	be 00 00 00 00       	mov    $0x0,%esi
f010081f:	eb 06                	jmp    f0100827 <monitor+0x47>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100821:	c6 03 00             	movb   $0x0,(%ebx)
f0100824:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100827:	0f b6 03             	movzbl (%ebx),%eax
f010082a:	84 c0                	test   %al,%al
f010082c:	74 6d                	je     f010089b <monitor+0xbb>
f010082e:	0f be c0             	movsbl %al,%eax
f0100831:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100835:	c7 04 24 16 20 10 f0 	movl   $0xf0102016,(%esp)
f010083c:	e8 ad 0f 00 00       	call   f01017ee <strchr>
f0100841:	85 c0                	test   %eax,%eax
f0100843:	75 dc                	jne    f0100821 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100845:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100848:	74 51                	je     f010089b <monitor+0xbb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010084a:	83 fe 0f             	cmp    $0xf,%esi
f010084d:	8d 76 00             	lea    0x0(%esi),%esi
f0100850:	75 16                	jne    f0100868 <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100852:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100859:	00 
f010085a:	c7 04 24 1b 20 10 f0 	movl   $0xf010201b,(%esp)
f0100861:	e8 ed 01 00 00       	call   f0100a53 <cprintf>
f0100866:	eb 99                	jmp    f0100801 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100868:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010086c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010086f:	0f b6 03             	movzbl (%ebx),%eax
f0100872:	84 c0                	test   %al,%al
f0100874:	75 0c                	jne    f0100882 <monitor+0xa2>
f0100876:	eb af                	jmp    f0100827 <monitor+0x47>
			buf++;
f0100878:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010087b:	0f b6 03             	movzbl (%ebx),%eax
f010087e:	84 c0                	test   %al,%al
f0100880:	74 a5                	je     f0100827 <monitor+0x47>
f0100882:	0f be c0             	movsbl %al,%eax
f0100885:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100889:	c7 04 24 16 20 10 f0 	movl   $0xf0102016,(%esp)
f0100890:	e8 59 0f 00 00       	call   f01017ee <strchr>
f0100895:	85 c0                	test   %eax,%eax
f0100897:	74 df                	je     f0100878 <monitor+0x98>
f0100899:	eb 8c                	jmp    f0100827 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f010089b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008a2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008a3:	85 f6                	test   %esi,%esi
f01008a5:	0f 84 56 ff ff ff    	je     f0100801 <monitor+0x21>
f01008ab:	bb 60 22 10 f0       	mov    $0xf0102260,%ebx
f01008b0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008b5:	8b 03                	mov    (%ebx),%eax
f01008b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008bb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008be:	89 04 24             	mov    %eax,(%esp)
f01008c1:	e8 b3 0e 00 00       	call   f0101779 <strcmp>
f01008c6:	85 c0                	test   %eax,%eax
f01008c8:	75 23                	jne    f01008ed <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f01008ca:	6b ff 0c             	imul   $0xc,%edi,%edi
f01008cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01008d0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008d4:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01008d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008db:	89 34 24             	mov    %esi,(%esp)
f01008de:	ff 97 68 22 10 f0    	call   *-0xfefdd98(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008e4:	85 c0                	test   %eax,%eax
f01008e6:	78 28                	js     f0100910 <monitor+0x130>
f01008e8:	e9 14 ff ff ff       	jmp    f0100801 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008ed:	83 c7 01             	add    $0x1,%edi
f01008f0:	83 c3 0c             	add    $0xc,%ebx
f01008f3:	83 ff 03             	cmp    $0x3,%edi
f01008f6:	75 bd                	jne    f01008b5 <monitor+0xd5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008f8:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ff:	c7 04 24 38 20 10 f0 	movl   $0xf0102038,(%esp)
f0100906:	e8 48 01 00 00       	call   f0100a53 <cprintf>
f010090b:	e9 f1 fe ff ff       	jmp    f0100801 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100910:	83 c4 5c             	add    $0x5c,%esp
f0100913:	5b                   	pop    %ebx
f0100914:	5e                   	pop    %esi
f0100915:	5f                   	pop    %edi
f0100916:	5d                   	pop    %ebp
f0100917:	c3                   	ret    

f0100918 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100918:	55                   	push   %ebp
f0100919:	89 e5                	mov    %esp,%ebp
f010091b:	57                   	push   %edi
f010091c:	56                   	push   %esi
f010091d:	53                   	push   %ebx
f010091e:	83 ec 5c             	sub    $0x5c,%esp
	uint32_t *ebp, *eip;
	uint32_t arg0, arg1, arg2, arg3, arg4;
	struct Eipdebuginfo eip_info;
	int j;

	ebp = (uint32_t *) read_ebp();
f0100921:	89 ee                	mov    %ebp,%esi
	eip = (uint32_t *) ebp[1];
f0100923:	8b 5e 04             	mov    0x4(%esi),%ebx
	arg0 = ebp[2];
f0100926:	8b 7e 08             	mov    0x8(%esi),%edi
	arg1 = ebp[3];
f0100929:	8b 46 0c             	mov    0xc(%esi),%eax
f010092c:	89 45 b8             	mov    %eax,-0x48(%ebp)
	arg2 = ebp[4];
f010092f:	8b 56 10             	mov    0x10(%esi),%edx
f0100932:	89 55 bc             	mov    %edx,-0x44(%ebp)
	arg3 = ebp[5];
f0100935:	8b 46 14             	mov    0x14(%esi),%eax
f0100938:	89 45 c0             	mov    %eax,-0x40(%ebp)
	arg4 = ebp[6];
f010093b:	8b 56 18             	mov    0x18(%esi),%edx
f010093e:	89 55 c4             	mov    %edx,-0x3c(%ebp)

	cprintf( "Stack backtrace: \n");
f0100941:	c7 04 24 4e 20 10 f0 	movl   $0xf010204e,(%esp)
f0100948:	e8 06 01 00 00       	call   f0100a53 <cprintf>
	while(ebp !=0)
f010094d:	85 f6                	test   %esi,%esi
f010094f:	0f 84 be 00 00 00    	je     f0100a13 <mon_backtrace+0xfb>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
			ebp,eip,arg0,arg1,arg2,arg3,arg4);

		debuginfo_eip((uint32_t)eip, &eip_info);
		cprintf("%s:%d: ",eip_info.eip_file , eip_info.eip_line);
		for(j=0;j<eip_info.eip_fn_namelen;j++)
f0100955:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100958:	8b 4d b8             	mov    -0x48(%ebp),%ecx
	arg4 = ebp[6];

	cprintf( "Stack backtrace: \n");
	while(ebp !=0)
	{
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f010095b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010095e:	89 54 24 1c          	mov    %edx,0x1c(%esp)
f0100962:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100966:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100969:	89 44 24 14          	mov    %eax,0x14(%esp)
f010096d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100971:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0100975:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100979:	89 74 24 04          	mov    %esi,0x4(%esp)
f010097d:	c7 04 24 00 22 10 f0 	movl   $0xf0102200,(%esp)
f0100984:	e8 ca 00 00 00       	call   f0100a53 <cprintf>
			ebp,eip,arg0,arg1,arg2,arg3,arg4);

		debuginfo_eip((uint32_t)eip, &eip_info);
f0100989:	89 df                	mov    %ebx,%edi
f010098b:	8d 55 d0             	lea    -0x30(%ebp),%edx
f010098e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100992:	89 1c 24             	mov    %ebx,(%esp)
f0100995:	e8 14 02 00 00       	call   f0100bae <debuginfo_eip>
		cprintf("%s:%d: ",eip_info.eip_file , eip_info.eip_line);
f010099a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010099d:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01009a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a8:	c7 04 24 4a 1d 10 f0 	movl   $0xf0101d4a,(%esp)
f01009af:	e8 9f 00 00 00       	call   f0100a53 <cprintf>
		for(j=0;j<eip_info.eip_fn_namelen;j++)
f01009b4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01009b8:	7e 24                	jle    f01009de <mon_backtrace+0xc6>
f01009ba:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf("%c", eip_info.eip_fn_name[j]);
f01009bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009c2:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f01009c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ca:	c7 04 24 61 20 10 f0 	movl   $0xf0102061,(%esp)
f01009d1:	e8 7d 00 00 00       	call   f0100a53 <cprintf>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
			ebp,eip,arg0,arg1,arg2,arg3,arg4);

		debuginfo_eip((uint32_t)eip, &eip_info);
		cprintf("%s:%d: ",eip_info.eip_file , eip_info.eip_line);
		for(j=0;j<eip_info.eip_fn_namelen;j++)
f01009d6:	83 c3 01             	add    $0x1,%ebx
f01009d9:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f01009dc:	7f e1                	jg     f01009bf <mon_backtrace+0xa7>
			cprintf("%c", eip_info.eip_fn_name[j]);
		//cprintf("+%d\n", eip - eip_info.eip_fn_addr);
		cprintf("+%d\n", (uint32_t)eip - eip_info.eip_fn_addr);
f01009de:	2b 7d e0             	sub    -0x20(%ebp),%edi
f01009e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01009e5:	c7 04 24 64 20 10 f0 	movl   $0xf0102064,(%esp)
f01009ec:	e8 62 00 00 00       	call   f0100a53 <cprintf>

		ebp = (uint32_t *)ebp[0];
f01009f1:	8b 36                	mov    (%esi),%esi
		eip = (uint32_t *)ebp[1];
f01009f3:	8b 5e 04             	mov    0x4(%esi),%ebx
		arg0 = ebp[2];
f01009f6:	8b 7e 08             	mov    0x8(%esi),%edi
		arg1 = ebp[3];
f01009f9:	8b 4e 0c             	mov    0xc(%esi),%ecx
		arg2 = ebp[4];
f01009fc:	8b 46 10             	mov    0x10(%esi),%eax
f01009ff:	89 45 bc             	mov    %eax,-0x44(%ebp)
		arg3 = ebp[5];
f0100a02:	8b 46 14             	mov    0x14(%esi),%eax
		arg4 = ebp[6];
f0100a05:	8b 56 18             	mov    0x18(%esi),%edx
f0100a08:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	arg2 = ebp[4];
	arg3 = ebp[5];
	arg4 = ebp[6];

	cprintf( "Stack backtrace: \n");
	while(ebp !=0)
f0100a0b:	85 f6                	test   %esi,%esi
f0100a0d:	0f 85 48 ff ff ff    	jne    f010095b <mon_backtrace+0x43>
		arg2 = ebp[4];
		arg3 = ebp[5];
		arg4 = ebp[6];
	}
	return 0;
}
f0100a13:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a18:	83 c4 5c             	add    $0x5c,%esp
f0100a1b:	5b                   	pop    %ebx
f0100a1c:	5e                   	pop    %esi
f0100a1d:	5f                   	pop    %edi
f0100a1e:	5d                   	pop    %ebp
f0100a1f:	c3                   	ret    

f0100a20 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100a20:	55                   	push   %ebp
f0100a21:	89 e5                	mov    %esp,%ebp
f0100a23:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100a26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a34:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a37:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a3e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a42:	c7 04 24 6d 0a 10 f0 	movl   $0xf0100a6d,(%esp)
f0100a49:	e8 e2 04 00 00       	call   f0100f30 <vprintfmt>
	return cnt;
}
f0100a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a51:	c9                   	leave  
f0100a52:	c3                   	ret    

f0100a53 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a53:	55                   	push   %ebp
f0100a54:	89 e5                	mov    %esp,%ebp
f0100a56:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100a59:	8d 45 0c             	lea    0xc(%ebp),%eax
f0100a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a60:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a63:	89 04 24             	mov    %eax,(%esp)
f0100a66:	e8 b5 ff ff ff       	call   f0100a20 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a6b:	c9                   	leave  
f0100a6c:	c3                   	ret    

f0100a6d <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a6d:	55                   	push   %ebp
f0100a6e:	89 e5                	mov    %esp,%ebp
f0100a70:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100a73:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a76:	89 04 24             	mov    %eax,(%esp)
f0100a79:	e8 3b fa ff ff       	call   f01004b9 <cputchar>
	*cnt++;
}
f0100a7e:	c9                   	leave  
f0100a7f:	c3                   	ret    

f0100a80 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a80:	55                   	push   %ebp
f0100a81:	89 e5                	mov    %esp,%ebp
f0100a83:	57                   	push   %edi
f0100a84:	56                   	push   %esi
f0100a85:	53                   	push   %ebx
f0100a86:	83 ec 14             	sub    $0x14,%esp
f0100a89:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a8c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100a8f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a92:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a95:	8b 1a                	mov    (%edx),%ebx
f0100a97:	8b 01                	mov    (%ecx),%eax
f0100a99:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0100a9c:	39 c3                	cmp    %eax,%ebx
f0100a9e:	0f 8f 9c 00 00 00    	jg     f0100b40 <stab_binsearch+0xc0>
f0100aa4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0100aab:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100aae:	01 d8                	add    %ebx,%eax
f0100ab0:	89 c7                	mov    %eax,%edi
f0100ab2:	c1 ef 1f             	shr    $0x1f,%edi
f0100ab5:	01 c7                	add    %eax,%edi
f0100ab7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100ab9:	39 df                	cmp    %ebx,%edi
f0100abb:	7c 33                	jl     f0100af0 <stab_binsearch+0x70>
f0100abd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100ac0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100ac3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100ac8:	39 f0                	cmp    %esi,%eax
f0100aca:	0f 84 bc 00 00 00    	je     f0100b8c <stab_binsearch+0x10c>
f0100ad0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0100ad4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0100ad8:	89 f8                	mov    %edi,%eax
			m--;
f0100ada:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100add:	39 d8                	cmp    %ebx,%eax
f0100adf:	7c 0f                	jl     f0100af0 <stab_binsearch+0x70>
f0100ae1:	0f b6 0a             	movzbl (%edx),%ecx
f0100ae4:	83 ea 0c             	sub    $0xc,%edx
f0100ae7:	39 f1                	cmp    %esi,%ecx
f0100ae9:	75 ef                	jne    f0100ada <stab_binsearch+0x5a>
f0100aeb:	e9 9e 00 00 00       	jmp    f0100b8e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100af0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100af3:	eb 3c                	jmp    f0100b31 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100af5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100af8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0100afa:	8d 5f 01             	lea    0x1(%edi),%ebx
f0100afd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100b04:	eb 2b                	jmp    f0100b31 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0100b06:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b09:	76 14                	jbe    f0100b1f <stab_binsearch+0x9f>
			*region_right = m - 1;
f0100b0b:	83 e8 01             	sub    $0x1,%eax
f0100b0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b11:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100b14:	89 02                	mov    %eax,(%edx)
f0100b16:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100b1d:	eb 12                	jmp    f0100b31 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b1f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100b22:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0100b24:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100b28:	89 c3                	mov    %eax,%ebx
f0100b2a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0100b31:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0100b34:	0f 8d 71 ff ff ff    	jge    f0100aab <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100b3a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100b3e:	75 0f                	jne    f0100b4f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0100b40:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100b43:	8b 03                	mov    (%ebx),%eax
f0100b45:	83 e8 01             	sub    $0x1,%eax
f0100b48:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100b4b:	89 02                	mov    %eax,(%edx)
f0100b4d:	eb 57                	jmp    f0100ba6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b4f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100b52:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b54:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100b57:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b59:	39 c1                	cmp    %eax,%ecx
f0100b5b:	7d 28                	jge    f0100b85 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0100b5d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b60:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100b63:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0100b68:	39 f2                	cmp    %esi,%edx
f0100b6a:	74 19                	je     f0100b85 <stab_binsearch+0x105>
f0100b6c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0100b70:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0100b74:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b77:	39 c1                	cmp    %eax,%ecx
f0100b79:	7d 0a                	jge    f0100b85 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0100b7b:	0f b6 1a             	movzbl (%edx),%ebx
f0100b7e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b81:	39 f3                	cmp    %esi,%ebx
f0100b83:	75 ef                	jne    f0100b74 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0100b85:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100b88:	89 02                	mov    %eax,(%edx)
f0100b8a:	eb 1a                	jmp    f0100ba6 <stab_binsearch+0x126>
	}
}
f0100b8c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b8e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b91:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0100b94:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b98:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b9b:	0f 82 54 ff ff ff    	jb     f0100af5 <stab_binsearch+0x75>
f0100ba1:	e9 60 ff ff ff       	jmp    f0100b06 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100ba6:	83 c4 14             	add    $0x14,%esp
f0100ba9:	5b                   	pop    %ebx
f0100baa:	5e                   	pop    %esi
f0100bab:	5f                   	pop    %edi
f0100bac:	5d                   	pop    %ebp
f0100bad:	c3                   	ret    

f0100bae <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100bae:	55                   	push   %ebp
f0100baf:	89 e5                	mov    %esp,%ebp
f0100bb1:	83 ec 48             	sub    $0x48,%esp
f0100bb4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100bb7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100bba:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100bbd:	8b 75 08             	mov    0x8(%ebp),%esi
f0100bc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100bc3:	c7 03 84 22 10 f0    	movl   $0xf0102284,(%ebx)
	info->eip_line = 0;
f0100bc9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100bd0:	c7 43 08 84 22 10 f0 	movl   $0xf0102284,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100bd7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100bde:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100be1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100be8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100bee:	76 12                	jbe    f0100c02 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100bf0:	b8 e8 7a 10 f0       	mov    $0xf0107ae8,%eax
f0100bf5:	3d 1d 61 10 f0       	cmp    $0xf010611d,%eax
f0100bfa:	0f 86 a2 01 00 00    	jbe    f0100da2 <debuginfo_eip+0x1f4>
f0100c00:	eb 1c                	jmp    f0100c1e <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100c02:	c7 44 24 08 8e 22 10 	movl   $0xf010228e,0x8(%esp)
f0100c09:	f0 
f0100c0a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100c11:	00 
f0100c12:	c7 04 24 9b 22 10 f0 	movl   $0xf010229b,(%esp)
f0100c19:	e8 62 f4 ff ff       	call   f0100080 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c1e:	80 3d e7 7a 10 f0 00 	cmpb   $0x0,0xf0107ae7
f0100c25:	0f 85 77 01 00 00    	jne    f0100da2 <debuginfo_eip+0x1f4>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c2b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c32:	b8 1c 61 10 f0       	mov    $0xf010611c,%eax
f0100c37:	2d e0 24 10 f0       	sub    $0xf01024e0,%eax
f0100c3c:	c1 f8 02             	sar    $0x2,%eax
f0100c3f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100c45:	83 e8 01             	sub    $0x1,%eax
f0100c48:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c4b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c4e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c51:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c55:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100c5c:	b8 e0 24 10 f0       	mov    $0xf01024e0,%eax
f0100c61:	e8 1a fe ff ff       	call   f0100a80 <stab_binsearch>
	if (lfile == 0)
f0100c66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c69:	85 c0                	test   %eax,%eax
f0100c6b:	0f 84 31 01 00 00    	je     f0100da2 <debuginfo_eip+0x1f4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c71:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c74:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c77:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c7a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c7d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c80:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c84:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100c8b:	b8 e0 24 10 f0       	mov    $0xf01024e0,%eax
f0100c90:	e8 eb fd ff ff       	call   f0100a80 <stab_binsearch>

	if (lfun <= rfun) {
f0100c95:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c98:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100c9b:	7f 3c                	jg     f0100cd9 <debuginfo_eip+0x12b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c9d:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100ca0:	8b 80 e0 24 10 f0    	mov    -0xfefdb20(%eax),%eax
f0100ca6:	ba e8 7a 10 f0       	mov    $0xf0107ae8,%edx
f0100cab:	81 ea 1d 61 10 f0    	sub    $0xf010611d,%edx
f0100cb1:	39 d0                	cmp    %edx,%eax
f0100cb3:	73 08                	jae    f0100cbd <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100cb5:	05 1d 61 10 f0       	add    $0xf010611d,%eax
f0100cba:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100cbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cc0:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100cc3:	8b 92 e8 24 10 f0    	mov    -0xfefdb18(%edx),%edx
f0100cc9:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100ccc:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100cce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100cd1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cd4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100cd7:	eb 0f                	jmp    f0100ce8 <debuginfo_eip+0x13a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100cd9:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100cdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cdf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100ce2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ce5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100ce8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100cef:	00 
f0100cf0:	8b 43 08             	mov    0x8(%ebx),%eax
f0100cf3:	89 04 24             	mov    %eax,(%esp)
f0100cf6:	e8 20 0b 00 00       	call   f010181b <strfind>
f0100cfb:	2b 43 08             	sub    0x8(%ebx),%eax
f0100cfe:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline , N_SLINE, addr);
f0100d01:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d04:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d07:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d0b:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100d12:	b8 e0 24 10 f0       	mov    $0xf01024e0,%eax
f0100d17:	e8 64 fd ff ff       	call   f0100a80 <stab_binsearch>
	if( lline <= rline)
f0100d1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d1f:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100d22:	0f 8f 7a 00 00 00    	jg     f0100da2 <debuginfo_eip+0x1f4>
	{
		info->eip_line = stabs[lline].n_desc;
f0100d28:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100d2b:	0f b7 80 e6 24 10 f0 	movzwl -0xfefdb1a(%eax),%eax
f0100d32:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0100d35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d3b:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100d3e:	81 c2 e8 24 10 f0    	add    $0xf01024e8,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d44:	eb 06                	jmp    f0100d4c <debuginfo_eip+0x19e>
f0100d46:	83 e8 01             	sub    $0x1,%eax
f0100d49:	83 ea 0c             	sub    $0xc,%edx
f0100d4c:	89 c6                	mov    %eax,%esi
f0100d4e:	39 f8                	cmp    %edi,%eax
f0100d50:	7c 1f                	jl     f0100d71 <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d52:	0f b6 4a fc          	movzbl -0x4(%edx),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d56:	80 f9 84             	cmp    $0x84,%cl
f0100d59:	74 60                	je     f0100dbb <debuginfo_eip+0x20d>
f0100d5b:	80 f9 64             	cmp    $0x64,%cl
f0100d5e:	75 e6                	jne    f0100d46 <debuginfo_eip+0x198>
f0100d60:	83 3a 00             	cmpl   $0x0,(%edx)
f0100d63:	74 e1                	je     f0100d46 <debuginfo_eip+0x198>
f0100d65:	8d 76 00             	lea    0x0(%esi),%esi
f0100d68:	eb 51                	jmp    f0100dbb <debuginfo_eip+0x20d>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100d6a:	05 1d 61 10 f0       	add    $0xf010611d,%eax
f0100d6f:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d71:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d74:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100d77:	7d 30                	jge    f0100da9 <debuginfo_eip+0x1fb>
		for (lline = lfun + 1;
f0100d79:	83 c0 01             	add    $0x1,%eax
f0100d7c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d7f:	ba e0 24 10 f0       	mov    $0xf01024e0,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100d84:	eb 08                	jmp    f0100d8e <debuginfo_eip+0x1e0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100d86:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100d8a:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100d91:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100d94:	7d 13                	jge    f0100da9 <debuginfo_eip+0x1fb>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d96:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100d99:	80 7c 10 04 a0       	cmpb   $0xa0,0x4(%eax,%edx,1)
f0100d9e:	74 e6                	je     f0100d86 <debuginfo_eip+0x1d8>
f0100da0:	eb 07                	jmp    f0100da9 <debuginfo_eip+0x1fb>
f0100da2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100da7:	eb 05                	jmp    f0100dae <debuginfo_eip+0x200>
f0100da9:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0100dae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100db1:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100db4:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100db7:	89 ec                	mov    %ebp,%esp
f0100db9:	5d                   	pop    %ebp
f0100dba:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100dbb:	6b c6 0c             	imul   $0xc,%esi,%eax
f0100dbe:	8b 80 e0 24 10 f0    	mov    -0xfefdb20(%eax),%eax
f0100dc4:	ba e8 7a 10 f0       	mov    $0xf0107ae8,%edx
f0100dc9:	81 ea 1d 61 10 f0    	sub    $0xf010611d,%edx
f0100dcf:	39 d0                	cmp    %edx,%eax
f0100dd1:	72 97                	jb     f0100d6a <debuginfo_eip+0x1bc>
f0100dd3:	eb 9c                	jmp    f0100d71 <debuginfo_eip+0x1c3>
	...

f0100de0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100de0:	55                   	push   %ebp
f0100de1:	89 e5                	mov    %esp,%ebp
f0100de3:	57                   	push   %edi
f0100de4:	56                   	push   %esi
f0100de5:	53                   	push   %ebx
f0100de6:	83 ec 4c             	sub    $0x4c,%esp
f0100de9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100dec:	89 d6                	mov    %edx,%esi
f0100dee:	8b 45 08             	mov    0x8(%ebp),%eax
f0100df1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100df4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100df7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100dfa:	8b 45 10             	mov    0x10(%ebp),%eax
f0100dfd:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100e00:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e03:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100e06:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e0b:	39 d1                	cmp    %edx,%ecx
f0100e0d:	72 15                	jb     f0100e24 <printnum+0x44>
f0100e0f:	77 07                	ja     f0100e18 <printnum+0x38>
f0100e11:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100e14:	39 d0                	cmp    %edx,%eax
f0100e16:	76 0c                	jbe    f0100e24 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100e18:	83 eb 01             	sub    $0x1,%ebx
f0100e1b:	85 db                	test   %ebx,%ebx
f0100e1d:	8d 76 00             	lea    0x0(%esi),%esi
f0100e20:	7f 61                	jg     f0100e83 <printnum+0xa3>
f0100e22:	eb 70                	jmp    f0100e94 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100e24:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0100e28:	83 eb 01             	sub    $0x1,%ebx
f0100e2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100e2f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e33:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0100e37:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0100e3b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100e3e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100e41:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100e48:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100e4f:	00 
f0100e50:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e53:	89 04 24             	mov    %eax,(%esp)
f0100e56:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100e59:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100e5d:	e8 4e 0c 00 00       	call   f0101ab0 <__udivdi3>
f0100e62:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100e65:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100e6c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100e70:	89 04 24             	mov    %eax,(%esp)
f0100e73:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100e77:	89 f2                	mov    %esi,%edx
f0100e79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e7c:	e8 5f ff ff ff       	call   f0100de0 <printnum>
f0100e81:	eb 11                	jmp    f0100e94 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100e83:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e87:	89 3c 24             	mov    %edi,(%esp)
f0100e8a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100e8d:	83 eb 01             	sub    $0x1,%ebx
f0100e90:	85 db                	test   %ebx,%ebx
f0100e92:	7f ef                	jg     f0100e83 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100e94:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e98:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100e9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e9f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ea3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100eaa:	00 
f0100eab:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100eae:	89 14 24             	mov    %edx,(%esp)
f0100eb1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100eb4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100eb8:	e8 23 0d 00 00       	call   f0101be0 <__umoddi3>
f0100ebd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ec1:	0f be 80 a9 22 10 f0 	movsbl -0xfefdd57(%eax),%eax
f0100ec8:	89 04 24             	mov    %eax,(%esp)
f0100ecb:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100ece:	83 c4 4c             	add    $0x4c,%esp
f0100ed1:	5b                   	pop    %ebx
f0100ed2:	5e                   	pop    %esi
f0100ed3:	5f                   	pop    %edi
f0100ed4:	5d                   	pop    %ebp
f0100ed5:	c3                   	ret    

f0100ed6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100ed6:	55                   	push   %ebp
f0100ed7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100ed9:	83 fa 01             	cmp    $0x1,%edx
f0100edc:	7e 0f                	jle    f0100eed <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f0100ede:	8b 10                	mov    (%eax),%edx
f0100ee0:	83 c2 08             	add    $0x8,%edx
f0100ee3:	89 10                	mov    %edx,(%eax)
f0100ee5:	8b 42 f8             	mov    -0x8(%edx),%eax
f0100ee8:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100eeb:	eb 24                	jmp    f0100f11 <getuint+0x3b>
	else if (lflag)
f0100eed:	85 d2                	test   %edx,%edx
f0100eef:	74 11                	je     f0100f02 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0100ef1:	8b 10                	mov    (%eax),%edx
f0100ef3:	83 c2 04             	add    $0x4,%edx
f0100ef6:	89 10                	mov    %edx,(%eax)
f0100ef8:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100efb:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f00:	eb 0f                	jmp    f0100f11 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f0100f02:	8b 10                	mov    (%eax),%edx
f0100f04:	83 c2 04             	add    $0x4,%edx
f0100f07:	89 10                	mov    %edx,(%eax)
f0100f09:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100f0c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100f11:	5d                   	pop    %ebp
f0100f12:	c3                   	ret    

f0100f13 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f13:	55                   	push   %ebp
f0100f14:	89 e5                	mov    %esp,%ebp
f0100f16:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f19:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f1d:	8b 10                	mov    (%eax),%edx
f0100f1f:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f22:	73 0a                	jae    f0100f2e <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f24:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100f27:	88 0a                	mov    %cl,(%edx)
f0100f29:	83 c2 01             	add    $0x1,%edx
f0100f2c:	89 10                	mov    %edx,(%eax)
}
f0100f2e:	5d                   	pop    %ebp
f0100f2f:	c3                   	ret    

f0100f30 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100f30:	55                   	push   %ebp
f0100f31:	89 e5                	mov    %esp,%ebp
f0100f33:	57                   	push   %edi
f0100f34:	56                   	push   %esi
f0100f35:	53                   	push   %ebx
f0100f36:	83 ec 5c             	sub    $0x5c,%esp
f0100f39:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100f3c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100f3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100f42:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0100f49:	eb 11                	jmp    f0100f5c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100f4b:	85 c0                	test   %eax,%eax
f0100f4d:	0f 84 bb 05 00 00    	je     f010150e <vprintfmt+0x5de>
				return;
			putch(ch, putdat);
f0100f53:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f57:	89 04 24             	mov    %eax,(%esp)
f0100f5a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100f5c:	0f b6 03             	movzbl (%ebx),%eax
f0100f5f:	83 c3 01             	add    $0x1,%ebx
f0100f62:	83 f8 25             	cmp    $0x25,%eax
f0100f65:	75 e4                	jne    f0100f4b <vprintfmt+0x1b>
f0100f67:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
f0100f6b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100f72:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0100f79:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0100f80:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f85:	eb 06                	jmp    f0100f8d <vprintfmt+0x5d>
f0100f87:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
f0100f8b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f8d:	0f b6 13             	movzbl (%ebx),%edx
f0100f90:	0f b6 c2             	movzbl %dl,%eax
f0100f93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f96:	8d 43 01             	lea    0x1(%ebx),%eax
f0100f99:	83 ea 23             	sub    $0x23,%edx
f0100f9c:	80 fa 55             	cmp    $0x55,%dl
f0100f9f:	0f 87 4c 05 00 00    	ja     f01014f1 <vprintfmt+0x5c1>
f0100fa5:	0f b6 d2             	movzbl %dl,%edx
f0100fa8:	ff 24 95 5c 23 10 f0 	jmp    *-0xfefdca4(,%edx,4)
f0100faf:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
f0100fb3:	eb d6                	jmp    f0100f8b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100fb5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100fb8:	83 ea 30             	sub    $0x30,%edx
f0100fbb:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
f0100fbe:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100fc1:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100fc4:	83 fb 09             	cmp    $0x9,%ebx
f0100fc7:	77 4d                	ja     f0101016 <vprintfmt+0xe6>
f0100fc9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100fcc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100fcf:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0100fd2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100fd5:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0100fd9:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100fdc:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100fdf:	83 fb 09             	cmp    $0x9,%ebx
f0100fe2:	76 eb                	jbe    f0100fcf <vprintfmt+0x9f>
f0100fe4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100fe7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100fea:	eb 2a                	jmp    f0101016 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100fec:	8b 55 14             	mov    0x14(%ebp),%edx
f0100fef:	83 c2 04             	add    $0x4,%edx
f0100ff2:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ff5:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100ff8:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
f0100ffb:	eb 19                	jmp    f0101016 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
f0100ffd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101000:	c1 fa 1f             	sar    $0x1f,%edx
f0101003:	f7 d2                	not    %edx
f0101005:	21 55 d4             	and    %edx,-0x2c(%ebp)
f0101008:	eb 81                	jmp    f0100f8b <vprintfmt+0x5b>
f010100a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0101011:	e9 75 ff ff ff       	jmp    f0100f8b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f0101016:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010101a:	0f 89 6b ff ff ff    	jns    f0100f8b <vprintfmt+0x5b>
f0101020:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101023:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0101026:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101029:	89 55 cc             	mov    %edx,-0x34(%ebp)
f010102c:	e9 5a ff ff ff       	jmp    f0100f8b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101031:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0101034:	e9 52 ff ff ff       	jmp    f0100f8b <vprintfmt+0x5b>
f0101039:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010103c:	8b 45 14             	mov    0x14(%ebp),%eax
f010103f:	83 c0 04             	add    $0x4,%eax
f0101042:	89 45 14             	mov    %eax,0x14(%ebp)
f0101045:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101049:	8b 40 fc             	mov    -0x4(%eax),%eax
f010104c:	89 04 24             	mov    %eax,(%esp)
f010104f:	ff d7                	call   *%edi
f0101051:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f0101054:	e9 03 ff ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
f0101059:	89 45 d0             	mov    %eax,-0x30(%ebp)

		//color control
		case 'C':
			memmove(sel_c, fmt,sizeof(unsigned char) * 3);
f010105c:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
f0101063:	00 
f0101064:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101068:	c7 04 24 a0 09 11 f0 	movl   $0xf01109a0,(%esp)
f010106f:	e8 31 08 00 00       	call   f01018a5 <memmove>
			sel_c[3] = '\0';
f0101074:	c6 05 a3 09 11 f0 00 	movb   $0x0,0xf01109a3
			fmt += 3;
f010107b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010107e:	83 c3 03             	add    $0x3,%ebx

			if(sel_c[0] >= '0' && sel_c[0] <= '9')
f0101081:	0f b6 05 a0 09 11 f0 	movzbl 0xf01109a0,%eax
f0101088:	8d 50 d0             	lea    -0x30(%eax),%edx
f010108b:	80 fa 09             	cmp    $0x9,%dl
f010108e:	77 2f                	ja     f01010bf <vprintfmt+0x18f>
			{
				ch_color = ((sel_c[0] - '0') * 10 + sel_c[1] - '0')*10 + sel_c[2] - '0';
f0101090:	0f be 15 a2 09 11 f0 	movsbl 0xf01109a2,%edx
f0101097:	0f be 0d a1 09 11 f0 	movsbl 0xf01109a1,%ecx
f010109e:	0f be c0             	movsbl %al,%eax
f01010a1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01010a4:	8d 84 41 20 fe ff ff 	lea    -0x1e0(%ecx,%eax,2),%eax
f01010ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01010ae:	8d 84 42 f0 fd ff ff 	lea    -0x210(%edx,%eax,2),%eax
f01010b5:	a3 20 03 11 f0       	mov    %eax,0xf0110320
f01010ba:	e9 9d fe ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
			}
			else
			{
				if(strcmp(sel_c, "wht") == 0)
f01010bf:	c7 44 24 04 ba 22 10 	movl   $0xf01022ba,0x4(%esp)
f01010c6:	f0 
f01010c7:	c7 04 24 a0 09 11 f0 	movl   $0xf01109a0,(%esp)
f01010ce:	e8 a6 06 00 00       	call   f0101779 <strcmp>
f01010d3:	85 c0                	test   %eax,%eax
f01010d5:	75 0f                	jne    f01010e6 <vprintfmt+0x1b6>
					ch_color = COLOR_WHT
f01010d7:	c7 05 20 03 11 f0 07 	movl   $0x7,0xf0110320
f01010de:	00 00 00 
f01010e1:	e9 76 fe ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
				else if(strcmp(sel_c, "blk") ==0)
f01010e6:	c7 44 24 04 be 22 10 	movl   $0xf01022be,0x4(%esp)
f01010ed:	f0 
f01010ee:	c7 04 24 a0 09 11 f0 	movl   $0xf01109a0,(%esp)
f01010f5:	e8 7f 06 00 00       	call   f0101779 <strcmp>
f01010fa:	85 c0                	test   %eax,%eax
f01010fc:	75 0f                	jne    f010110d <vprintfmt+0x1dd>
					ch_color = COLOR_BLK
f01010fe:	c7 05 20 03 11 f0 01 	movl   $0x1,0xf0110320
f0101105:	00 00 00 
f0101108:	e9 4f fe ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
				else if(strcmp(sel_c, "grn") == 0)
f010110d:	c7 44 24 04 c2 22 10 	movl   $0xf01022c2,0x4(%esp)
f0101114:	f0 
f0101115:	c7 04 24 a0 09 11 f0 	movl   $0xf01109a0,(%esp)
f010111c:	e8 58 06 00 00       	call   f0101779 <strcmp>
f0101121:	85 c0                	test   %eax,%eax
f0101123:	75 0f                	jne    f0101134 <vprintfmt+0x204>
					ch_color = COLOR_GRN
f0101125:	c7 05 20 03 11 f0 02 	movl   $0x2,0xf0110320
f010112c:	00 00 00 
f010112f:	e9 28 fe ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
				else if(strcmp( sel_c , "red") == 0)
f0101134:	c7 44 24 04 c6 22 10 	movl   $0xf01022c6,0x4(%esp)
f010113b:	f0 
f010113c:	c7 04 24 a0 09 11 f0 	movl   $0xf01109a0,(%esp)
f0101143:	e8 31 06 00 00       	call   f0101779 <strcmp>
f0101148:	85 c0                	test   %eax,%eax
f010114a:	75 0f                	jne    f010115b <vprintfmt+0x22b>
					ch_color = COLOR_RED
f010114c:	c7 05 20 03 11 f0 04 	movl   $0x4,0xf0110320
f0101153:	00 00 00 
f0101156:	e9 01 fe ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
				else if( strcmp( sel_c, "gry") == 0)
f010115b:	c7 44 24 04 ca 22 10 	movl   $0xf01022ca,0x4(%esp)
f0101162:	f0 
f0101163:	c7 04 24 a0 09 11 f0 	movl   $0xf01109a0,(%esp)
f010116a:	e8 0a 06 00 00       	call   f0101779 <strcmp>
f010116f:	85 c0                	test   %eax,%eax
f0101171:	75 0f                	jne    f0101182 <vprintfmt+0x252>
					ch_color = COLOR_GRY
f0101173:	c7 05 20 03 11 f0 08 	movl   $0x8,0xf0110320
f010117a:	00 00 00 
f010117d:	e9 da fd ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
				else if(strcmp (sel_c, "ylw") == 0)
f0101182:	c7 44 24 04 ce 22 10 	movl   $0xf01022ce,0x4(%esp)
f0101189:	f0 
f010118a:	c7 04 24 a0 09 11 f0 	movl   $0xf01109a0,(%esp)
f0101191:	e8 e3 05 00 00       	call   f0101779 <strcmp>
f0101196:	85 c0                	test   %eax,%eax
f0101198:	75 0f                	jne    f01011a9 <vprintfmt+0x279>
					ch_color = COLOR_YLW
f010119a:	c7 05 20 03 11 f0 0f 	movl   $0xf,0xf0110320
f01011a1:	00 00 00 
f01011a4:	e9 b3 fd ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
				else if ( strcmp( sel_c, "org") == 0)
f01011a9:	c7 44 24 04 d2 22 10 	movl   $0xf01022d2,0x4(%esp)
f01011b0:	f0 
f01011b1:	c7 04 24 a0 09 11 f0 	movl   $0xf01109a0,(%esp)
f01011b8:	e8 bc 05 00 00       	call   f0101779 <strcmp>
f01011bd:	85 c0                	test   %eax,%eax
f01011bf:	75 0f                	jne    f01011d0 <vprintfmt+0x2a0>
					ch_color = COLOR_ORG
f01011c1:	c7 05 20 03 11 f0 0c 	movl   $0xc,0xf0110320
f01011c8:	00 00 00 
f01011cb:	e9 8c fd ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
				else if ( strcmp(sel_c, "pur") == 0)
f01011d0:	c7 44 24 04 d6 22 10 	movl   $0xf01022d6,0x4(%esp)
f01011d7:	f0 
f01011d8:	c7 04 24 a0 09 11 f0 	movl   $0xf01109a0,(%esp)
f01011df:	e8 95 05 00 00       	call   f0101779 <strcmp>
f01011e4:	85 c0                	test   %eax,%eax
f01011e6:	75 0f                	jne    f01011f7 <vprintfmt+0x2c7>
					ch_color = COLOR_PUR
f01011e8:	c7 05 20 03 11 f0 06 	movl   $0x6,0xf0110320
f01011ef:	00 00 00 
f01011f2:	e9 65 fd ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
				else if (strcmp (sel_c, "cyn") == 0)
f01011f7:	c7 44 24 04 da 22 10 	movl   $0xf01022da,0x4(%esp)
f01011fe:	f0 
f01011ff:	c7 04 24 a0 09 11 f0 	movl   $0xf01109a0,(%esp)
f0101206:	e8 6e 05 00 00       	call   f0101779 <strcmp>
					ch_color = COLOR_CYN
f010120b:	83 f8 01             	cmp    $0x1,%eax
f010120e:	19 c0                	sbb    %eax,%eax
f0101210:	83 e0 04             	and    $0x4,%eax
f0101213:	83 c0 07             	add    $0x7,%eax
f0101216:	a3 20 03 11 f0       	mov    %eax,0xf0110320
f010121b:	e9 3c fd ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
f0101220:	89 45 d0             	mov    %eax,-0x30(%ebp)
			}
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101223:	8b 45 14             	mov    0x14(%ebp),%eax
f0101226:	83 c0 04             	add    $0x4,%eax
f0101229:	89 45 14             	mov    %eax,0x14(%ebp)
f010122c:	8b 40 fc             	mov    -0x4(%eax),%eax
f010122f:	89 c2                	mov    %eax,%edx
f0101231:	c1 fa 1f             	sar    $0x1f,%edx
f0101234:	31 d0                	xor    %edx,%eax
f0101236:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0101238:	83 f8 06             	cmp    $0x6,%eax
f010123b:	7f 0b                	jg     f0101248 <vprintfmt+0x318>
f010123d:	8b 14 85 b4 24 10 f0 	mov    -0xfefdb4c(,%eax,4),%edx
f0101244:	85 d2                	test   %edx,%edx
f0101246:	75 20                	jne    f0101268 <vprintfmt+0x338>
				printfmt(putch, putdat, "error %d", err);
f0101248:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010124c:	c7 44 24 08 de 22 10 	movl   $0xf01022de,0x8(%esp)
f0101253:	f0 
f0101254:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101258:	89 3c 24             	mov    %edi,(%esp)
f010125b:	e8 36 03 00 00       	call   f0101596 <printfmt>
f0101260:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0101263:	e9 f4 fc ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0101268:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010126c:	c7 44 24 08 e7 22 10 	movl   $0xf01022e7,0x8(%esp)
f0101273:	f0 
f0101274:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101278:	89 3c 24             	mov    %edi,(%esp)
f010127b:	e8 16 03 00 00       	call   f0101596 <printfmt>
f0101280:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101283:	e9 d4 fc ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
f0101288:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010128b:	89 c3                	mov    %eax,%ebx
f010128d:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101290:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101293:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101296:	8b 45 14             	mov    0x14(%ebp),%eax
f0101299:	83 c0 04             	add    $0x4,%eax
f010129c:	89 45 14             	mov    %eax,0x14(%ebp)
f010129f:	8b 40 fc             	mov    -0x4(%eax),%eax
f01012a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01012a5:	85 c0                	test   %eax,%eax
f01012a7:	75 07                	jne    f01012b0 <vprintfmt+0x380>
f01012a9:	c7 45 e4 ea 22 10 f0 	movl   $0xf01022ea,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f01012b0:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f01012b4:	7e 06                	jle    f01012bc <vprintfmt+0x38c>
f01012b6:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
f01012ba:	75 13                	jne    f01012cf <vprintfmt+0x39f>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01012bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01012bf:	0f be 02             	movsbl (%edx),%eax
f01012c2:	85 c0                	test   %eax,%eax
f01012c4:	0f 85 a2 00 00 00    	jne    f010136c <vprintfmt+0x43c>
f01012ca:	e9 8f 00 00 00       	jmp    f010135e <vprintfmt+0x42e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01012cf:	89 54 24 04          	mov    %edx,0x4(%esp)
f01012d3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01012d6:	89 0c 24             	mov    %ecx,(%esp)
f01012d9:	e8 dd 03 00 00       	call   f01016bb <strnlen>
f01012de:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01012e1:	29 c2                	sub    %eax,%edx
f01012e3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01012e6:	85 d2                	test   %edx,%edx
f01012e8:	7e d2                	jle    f01012bc <vprintfmt+0x38c>
					putch(padc, putdat);
f01012ea:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f01012ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01012f1:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f01012f4:	89 d3                	mov    %edx,%ebx
f01012f6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01012fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01012fd:	89 04 24             	mov    %eax,(%esp)
f0101300:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101302:	83 eb 01             	sub    $0x1,%ebx
f0101305:	85 db                	test   %ebx,%ebx
f0101307:	7f ed                	jg     f01012f6 <vprintfmt+0x3c6>
f0101309:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010130c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101313:	eb a7                	jmp    f01012bc <vprintfmt+0x38c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101315:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101319:	74 1b                	je     f0101336 <vprintfmt+0x406>
f010131b:	8d 50 e0             	lea    -0x20(%eax),%edx
f010131e:	83 fa 5e             	cmp    $0x5e,%edx
f0101321:	76 13                	jbe    f0101336 <vprintfmt+0x406>
					putch('?', putdat);
f0101323:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101326:	89 54 24 04          	mov    %edx,0x4(%esp)
f010132a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101331:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101334:	eb 0d                	jmp    f0101343 <vprintfmt+0x413>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0101336:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101339:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010133d:	89 04 24             	mov    %eax,(%esp)
f0101340:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101343:	83 ef 01             	sub    $0x1,%edi
f0101346:	0f be 03             	movsbl (%ebx),%eax
f0101349:	85 c0                	test   %eax,%eax
f010134b:	74 05                	je     f0101352 <vprintfmt+0x422>
f010134d:	83 c3 01             	add    $0x1,%ebx
f0101350:	eb 31                	jmp    f0101383 <vprintfmt+0x453>
f0101352:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101358:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010135b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010135e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101362:	7f 36                	jg     f010139a <vprintfmt+0x46a>
f0101364:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101367:	e9 f0 fb ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010136c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010136f:	83 c2 01             	add    $0x1,%edx
f0101372:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0101375:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101378:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010137b:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010137e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101381:	89 d3                	mov    %edx,%ebx
f0101383:	85 f6                	test   %esi,%esi
f0101385:	78 8e                	js     f0101315 <vprintfmt+0x3e5>
f0101387:	83 ee 01             	sub    $0x1,%esi
f010138a:	79 89                	jns    f0101315 <vprintfmt+0x3e5>
f010138c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010138f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101392:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101395:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0101398:	eb c4                	jmp    f010135e <vprintfmt+0x42e>
f010139a:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f010139d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01013a0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013a4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01013ab:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01013ad:	83 eb 01             	sub    $0x1,%ebx
f01013b0:	85 db                	test   %ebx,%ebx
f01013b2:	7f ec                	jg     f01013a0 <vprintfmt+0x470>
f01013b4:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01013b7:	e9 a0 fb ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
f01013bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01013bf:	83 f9 01             	cmp    $0x1,%ecx
f01013c2:	7e 17                	jle    f01013db <vprintfmt+0x4ab>
		return va_arg(*ap, long long);
f01013c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01013c7:	83 c0 08             	add    $0x8,%eax
f01013ca:	89 45 14             	mov    %eax,0x14(%ebp)
f01013cd:	8b 50 f8             	mov    -0x8(%eax),%edx
f01013d0:	8b 48 fc             	mov    -0x4(%eax),%ecx
f01013d3:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01013d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01013d9:	eb 34                	jmp    f010140f <vprintfmt+0x4df>
	else if (lflag)
f01013db:	85 c9                	test   %ecx,%ecx
f01013dd:	74 19                	je     f01013f8 <vprintfmt+0x4c8>
		return va_arg(*ap, long);
f01013df:	8b 45 14             	mov    0x14(%ebp),%eax
f01013e2:	83 c0 04             	add    $0x4,%eax
f01013e5:	89 45 14             	mov    %eax,0x14(%ebp)
f01013e8:	8b 40 fc             	mov    -0x4(%eax),%eax
f01013eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01013ee:	89 c1                	mov    %eax,%ecx
f01013f0:	c1 f9 1f             	sar    $0x1f,%ecx
f01013f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01013f6:	eb 17                	jmp    f010140f <vprintfmt+0x4df>
	else
		return va_arg(*ap, int);
f01013f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01013fb:	83 c0 04             	add    $0x4,%eax
f01013fe:	89 45 14             	mov    %eax,0x14(%ebp)
f0101401:	8b 40 fc             	mov    -0x4(%eax),%eax
f0101404:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101407:	89 c2                	mov    %eax,%edx
f0101409:	c1 fa 1f             	sar    $0x1f,%edx
f010140c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010140f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101412:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101415:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
f010141a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010141e:	0f 89 8b 00 00 00    	jns    f01014af <vprintfmt+0x57f>
				putch('-', putdat);
f0101424:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101428:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010142f:	ff d7                	call   *%edi
				num = -(long long) num;
f0101431:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101434:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101437:	f7 d8                	neg    %eax
f0101439:	83 d2 00             	adc    $0x0,%edx
f010143c:	f7 da                	neg    %edx
f010143e:	eb 6f                	jmp    f01014af <vprintfmt+0x57f>
f0101440:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101443:	89 ca                	mov    %ecx,%edx
f0101445:	8d 45 14             	lea    0x14(%ebp),%eax
f0101448:	e8 89 fa ff ff       	call   f0100ed6 <getuint>
f010144d:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
f0101452:	eb 5b                	jmp    f01014af <vprintfmt+0x57f>
f0101454:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
		//	putch('X', putdat);
		//	putch('X', putdat);
		//	putch('X', putdat);
			num = getuint(&ap,lflag);
f0101457:	89 ca                	mov    %ecx,%edx
f0101459:	8d 45 14             	lea    0x14(%ebp),%eax
f010145c:	e8 75 fa ff ff       	call   f0100ed6 <getuint>
f0101461:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
f0101466:	eb 47                	jmp    f01014af <vprintfmt+0x57f>
f0101468:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f010146b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010146f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101476:	ff d7                	call   *%edi
			putch('x', putdat);
f0101478:	89 74 24 04          	mov    %esi,0x4(%esp)
f010147c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101483:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101485:	8b 45 14             	mov    0x14(%ebp),%eax
f0101488:	83 c0 04             	add    $0x4,%eax
f010148b:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010148e:	8b 40 fc             	mov    -0x4(%eax),%eax
f0101491:	ba 00 00 00 00       	mov    $0x0,%edx
f0101496:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010149b:	eb 12                	jmp    f01014af <vprintfmt+0x57f>
f010149d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01014a0:	89 ca                	mov    %ecx,%edx
f01014a2:	8d 45 14             	lea    0x14(%ebp),%eax
f01014a5:	e8 2c fa ff ff       	call   f0100ed6 <getuint>
f01014aa:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f01014af:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f01014b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01014b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01014ba:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01014be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01014c2:	89 04 24             	mov    %eax,(%esp)
f01014c5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01014c9:	89 f2                	mov    %esi,%edx
f01014cb:	89 f8                	mov    %edi,%eax
f01014cd:	e8 0e f9 ff ff       	call   f0100de0 <printnum>
f01014d2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f01014d5:	e9 82 fa ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
f01014da:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01014dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01014e0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01014e4:	89 14 24             	mov    %edx,(%esp)
f01014e7:	ff d7                	call   *%edi
f01014e9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f01014ec:	e9 6b fa ff ff       	jmp    f0100f5c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01014f1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01014f5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01014fc:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01014fe:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101501:	80 38 25             	cmpb   $0x25,(%eax)
f0101504:	0f 84 52 fa ff ff    	je     f0100f5c <vprintfmt+0x2c>
f010150a:	89 c3                	mov    %eax,%ebx
f010150c:	eb f0                	jmp    f01014fe <vprintfmt+0x5ce>
				/* do nothing */;
			break;
		}
	}
}
f010150e:	83 c4 5c             	add    $0x5c,%esp
f0101511:	5b                   	pop    %ebx
f0101512:	5e                   	pop    %esi
f0101513:	5f                   	pop    %edi
f0101514:	5d                   	pop    %ebp
f0101515:	c3                   	ret    

f0101516 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101516:	55                   	push   %ebp
f0101517:	89 e5                	mov    %esp,%ebp
f0101519:	83 ec 28             	sub    $0x28,%esp
f010151c:	8b 45 08             	mov    0x8(%ebp),%eax
f010151f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0101522:	85 c0                	test   %eax,%eax
f0101524:	74 04                	je     f010152a <vsnprintf+0x14>
f0101526:	85 d2                	test   %edx,%edx
f0101528:	7f 07                	jg     f0101531 <vsnprintf+0x1b>
f010152a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010152f:	eb 3b                	jmp    f010156c <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101531:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101534:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0101538:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010153b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101542:	8b 45 14             	mov    0x14(%ebp),%eax
f0101545:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101549:	8b 45 10             	mov    0x10(%ebp),%eax
f010154c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101550:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101553:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101557:	c7 04 24 13 0f 10 f0 	movl   $0xf0100f13,(%esp)
f010155e:	e8 cd f9 ff ff       	call   f0100f30 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101563:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101566:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101569:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f010156c:	c9                   	leave  
f010156d:	c3                   	ret    

f010156e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010156e:	55                   	push   %ebp
f010156f:	89 e5                	mov    %esp,%ebp
f0101571:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0101574:	8d 45 14             	lea    0x14(%ebp),%eax
f0101577:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010157b:	8b 45 10             	mov    0x10(%ebp),%eax
f010157e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101582:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101585:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101589:	8b 45 08             	mov    0x8(%ebp),%eax
f010158c:	89 04 24             	mov    %eax,(%esp)
f010158f:	e8 82 ff ff ff       	call   f0101516 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101594:	c9                   	leave  
f0101595:	c3                   	ret    

f0101596 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101596:	55                   	push   %ebp
f0101597:	89 e5                	mov    %esp,%ebp
f0101599:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f010159c:	8d 45 14             	lea    0x14(%ebp),%eax
f010159f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015a3:	8b 45 10             	mov    0x10(%ebp),%eax
f01015a6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01015aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01015b4:	89 04 24             	mov    %eax,(%esp)
f01015b7:	e8 74 f9 ff ff       	call   f0100f30 <vprintfmt>
	va_end(ap);
}
f01015bc:	c9                   	leave  
f01015bd:	c3                   	ret    
	...

f01015c0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01015c0:	55                   	push   %ebp
f01015c1:	89 e5                	mov    %esp,%ebp
f01015c3:	57                   	push   %edi
f01015c4:	56                   	push   %esi
f01015c5:	53                   	push   %ebx
f01015c6:	83 ec 1c             	sub    $0x1c,%esp
f01015c9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01015cc:	85 c0                	test   %eax,%eax
f01015ce:	74 10                	je     f01015e0 <readline+0x20>
		cprintf("%s", prompt);
f01015d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015d4:	c7 04 24 e7 22 10 f0 	movl   $0xf01022e7,(%esp)
f01015db:	e8 73 f4 ff ff       	call   f0100a53 <cprintf>

	i = 0;
	echoing = iscons(0);
f01015e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015e7:	e8 ca ec ff ff       	call   f01002b6 <iscons>
f01015ec:	89 c7                	mov    %eax,%edi
f01015ee:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f01015f3:	e8 ad ec ff ff       	call   f01002a5 <getchar>
f01015f8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01015fa:	85 c0                	test   %eax,%eax
f01015fc:	79 17                	jns    f0101615 <readline+0x55>
			cprintf("read error: %e\n", c);
f01015fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101602:	c7 04 24 d0 24 10 f0 	movl   $0xf01024d0,(%esp)
f0101609:	e8 45 f4 ff ff       	call   f0100a53 <cprintf>
f010160e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0101613:	eb 76                	jmp    f010168b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101615:	83 f8 08             	cmp    $0x8,%eax
f0101618:	74 08                	je     f0101622 <readline+0x62>
f010161a:	83 f8 7f             	cmp    $0x7f,%eax
f010161d:	8d 76 00             	lea    0x0(%esi),%esi
f0101620:	75 19                	jne    f010163b <readline+0x7b>
f0101622:	85 f6                	test   %esi,%esi
f0101624:	7e 15                	jle    f010163b <readline+0x7b>
			if (echoing)
f0101626:	85 ff                	test   %edi,%edi
f0101628:	74 0c                	je     f0101636 <readline+0x76>
				cputchar('\b');
f010162a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101631:	e8 83 ee ff ff       	call   f01004b9 <cputchar>
			i--;
f0101636:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101639:	eb b8                	jmp    f01015f3 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f010163b:	83 fb 1f             	cmp    $0x1f,%ebx
f010163e:	66 90                	xchg   %ax,%ax
f0101640:	7e 23                	jle    f0101665 <readline+0xa5>
f0101642:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101648:	7f 1b                	jg     f0101665 <readline+0xa5>
			if (echoing)
f010164a:	85 ff                	test   %edi,%edi
f010164c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101650:	74 08                	je     f010165a <readline+0x9a>
				cputchar(c);
f0101652:	89 1c 24             	mov    %ebx,(%esp)
f0101655:	e8 5f ee ff ff       	call   f01004b9 <cputchar>
			buf[i++] = c;
f010165a:	88 9e a0 05 11 f0    	mov    %bl,-0xfeefa60(%esi)
f0101660:	83 c6 01             	add    $0x1,%esi
f0101663:	eb 8e                	jmp    f01015f3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101665:	83 fb 0a             	cmp    $0xa,%ebx
f0101668:	74 05                	je     f010166f <readline+0xaf>
f010166a:	83 fb 0d             	cmp    $0xd,%ebx
f010166d:	75 84                	jne    f01015f3 <readline+0x33>
			if (echoing)
f010166f:	85 ff                	test   %edi,%edi
f0101671:	74 0c                	je     f010167f <readline+0xbf>
				cputchar('\n');
f0101673:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010167a:	e8 3a ee ff ff       	call   f01004b9 <cputchar>
			buf[i] = 0;
f010167f:	c6 86 a0 05 11 f0 00 	movb   $0x0,-0xfeefa60(%esi)
f0101686:	b8 a0 05 11 f0       	mov    $0xf01105a0,%eax
			return buf;
		}
	}
}
f010168b:	83 c4 1c             	add    $0x1c,%esp
f010168e:	5b                   	pop    %ebx
f010168f:	5e                   	pop    %esi
f0101690:	5f                   	pop    %edi
f0101691:	5d                   	pop    %ebp
f0101692:	c3                   	ret    
	...

f01016a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01016a0:	55                   	push   %ebp
f01016a1:	89 e5                	mov    %esp,%ebp
f01016a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01016a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01016ab:	80 3a 00             	cmpb   $0x0,(%edx)
f01016ae:	74 09                	je     f01016b9 <strlen+0x19>
		n++;
f01016b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01016b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01016b7:	75 f7                	jne    f01016b0 <strlen+0x10>
		n++;
	return n;
}
f01016b9:	5d                   	pop    %ebp
f01016ba:	c3                   	ret    

f01016bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01016bb:	55                   	push   %ebp
f01016bc:	89 e5                	mov    %esp,%ebp
f01016be:	53                   	push   %ebx
f01016bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01016c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01016c5:	85 c9                	test   %ecx,%ecx
f01016c7:	74 19                	je     f01016e2 <strnlen+0x27>
f01016c9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01016cc:	74 14                	je     f01016e2 <strnlen+0x27>
f01016ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01016d3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01016d6:	39 c8                	cmp    %ecx,%eax
f01016d8:	74 0d                	je     f01016e7 <strnlen+0x2c>
f01016da:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f01016de:	75 f3                	jne    f01016d3 <strnlen+0x18>
f01016e0:	eb 05                	jmp    f01016e7 <strnlen+0x2c>
f01016e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01016e7:	5b                   	pop    %ebx
f01016e8:	5d                   	pop    %ebp
f01016e9:	c3                   	ret    

f01016ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01016ea:	55                   	push   %ebp
f01016eb:	89 e5                	mov    %esp,%ebp
f01016ed:	53                   	push   %ebx
f01016ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01016f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01016f4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01016f9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01016fd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101700:	83 c2 01             	add    $0x1,%edx
f0101703:	84 c9                	test   %cl,%cl
f0101705:	75 f2                	jne    f01016f9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101707:	5b                   	pop    %ebx
f0101708:	5d                   	pop    %ebp
f0101709:	c3                   	ret    

f010170a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010170a:	55                   	push   %ebp
f010170b:	89 e5                	mov    %esp,%ebp
f010170d:	56                   	push   %esi
f010170e:	53                   	push   %ebx
f010170f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101712:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101715:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101718:	85 f6                	test   %esi,%esi
f010171a:	74 18                	je     f0101734 <strncpy+0x2a>
f010171c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101721:	0f b6 1a             	movzbl (%edx),%ebx
f0101724:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101727:	80 3a 01             	cmpb   $0x1,(%edx)
f010172a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010172d:	83 c1 01             	add    $0x1,%ecx
f0101730:	39 ce                	cmp    %ecx,%esi
f0101732:	77 ed                	ja     f0101721 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101734:	5b                   	pop    %ebx
f0101735:	5e                   	pop    %esi
f0101736:	5d                   	pop    %ebp
f0101737:	c3                   	ret    

f0101738 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101738:	55                   	push   %ebp
f0101739:	89 e5                	mov    %esp,%ebp
f010173b:	56                   	push   %esi
f010173c:	53                   	push   %ebx
f010173d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101740:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101743:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101746:	89 f0                	mov    %esi,%eax
f0101748:	85 c9                	test   %ecx,%ecx
f010174a:	74 27                	je     f0101773 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f010174c:	83 e9 01             	sub    $0x1,%ecx
f010174f:	74 1d                	je     f010176e <strlcpy+0x36>
f0101751:	0f b6 1a             	movzbl (%edx),%ebx
f0101754:	84 db                	test   %bl,%bl
f0101756:	74 16                	je     f010176e <strlcpy+0x36>
			*dst++ = *src++;
f0101758:	88 18                	mov    %bl,(%eax)
f010175a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010175d:	83 e9 01             	sub    $0x1,%ecx
f0101760:	74 0e                	je     f0101770 <strlcpy+0x38>
			*dst++ = *src++;
f0101762:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101765:	0f b6 1a             	movzbl (%edx),%ebx
f0101768:	84 db                	test   %bl,%bl
f010176a:	75 ec                	jne    f0101758 <strlcpy+0x20>
f010176c:	eb 02                	jmp    f0101770 <strlcpy+0x38>
f010176e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101770:	c6 00 00             	movb   $0x0,(%eax)
f0101773:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101775:	5b                   	pop    %ebx
f0101776:	5e                   	pop    %esi
f0101777:	5d                   	pop    %ebp
f0101778:	c3                   	ret    

f0101779 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101779:	55                   	push   %ebp
f010177a:	89 e5                	mov    %esp,%ebp
f010177c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010177f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101782:	0f b6 01             	movzbl (%ecx),%eax
f0101785:	84 c0                	test   %al,%al
f0101787:	74 15                	je     f010179e <strcmp+0x25>
f0101789:	3a 02                	cmp    (%edx),%al
f010178b:	75 11                	jne    f010179e <strcmp+0x25>
		p++, q++;
f010178d:	83 c1 01             	add    $0x1,%ecx
f0101790:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101793:	0f b6 01             	movzbl (%ecx),%eax
f0101796:	84 c0                	test   %al,%al
f0101798:	74 04                	je     f010179e <strcmp+0x25>
f010179a:	3a 02                	cmp    (%edx),%al
f010179c:	74 ef                	je     f010178d <strcmp+0x14>
f010179e:	0f b6 c0             	movzbl %al,%eax
f01017a1:	0f b6 12             	movzbl (%edx),%edx
f01017a4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01017a6:	5d                   	pop    %ebp
f01017a7:	c3                   	ret    

f01017a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01017a8:	55                   	push   %ebp
f01017a9:	89 e5                	mov    %esp,%ebp
f01017ab:	53                   	push   %ebx
f01017ac:	8b 55 08             	mov    0x8(%ebp),%edx
f01017af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01017b2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01017b5:	85 c0                	test   %eax,%eax
f01017b7:	74 23                	je     f01017dc <strncmp+0x34>
f01017b9:	0f b6 1a             	movzbl (%edx),%ebx
f01017bc:	84 db                	test   %bl,%bl
f01017be:	74 24                	je     f01017e4 <strncmp+0x3c>
f01017c0:	3a 19                	cmp    (%ecx),%bl
f01017c2:	75 20                	jne    f01017e4 <strncmp+0x3c>
f01017c4:	83 e8 01             	sub    $0x1,%eax
f01017c7:	74 13                	je     f01017dc <strncmp+0x34>
		n--, p++, q++;
f01017c9:	83 c2 01             	add    $0x1,%edx
f01017cc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01017cf:	0f b6 1a             	movzbl (%edx),%ebx
f01017d2:	84 db                	test   %bl,%bl
f01017d4:	74 0e                	je     f01017e4 <strncmp+0x3c>
f01017d6:	3a 19                	cmp    (%ecx),%bl
f01017d8:	74 ea                	je     f01017c4 <strncmp+0x1c>
f01017da:	eb 08                	jmp    f01017e4 <strncmp+0x3c>
f01017dc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01017e1:	5b                   	pop    %ebx
f01017e2:	5d                   	pop    %ebp
f01017e3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01017e4:	0f b6 02             	movzbl (%edx),%eax
f01017e7:	0f b6 11             	movzbl (%ecx),%edx
f01017ea:	29 d0                	sub    %edx,%eax
f01017ec:	eb f3                	jmp    f01017e1 <strncmp+0x39>

f01017ee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01017ee:	55                   	push   %ebp
f01017ef:	89 e5                	mov    %esp,%ebp
f01017f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01017f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017f8:	0f b6 10             	movzbl (%eax),%edx
f01017fb:	84 d2                	test   %dl,%dl
f01017fd:	74 15                	je     f0101814 <strchr+0x26>
		if (*s == c)
f01017ff:	38 ca                	cmp    %cl,%dl
f0101801:	75 07                	jne    f010180a <strchr+0x1c>
f0101803:	eb 14                	jmp    f0101819 <strchr+0x2b>
f0101805:	38 ca                	cmp    %cl,%dl
f0101807:	90                   	nop
f0101808:	74 0f                	je     f0101819 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010180a:	83 c0 01             	add    $0x1,%eax
f010180d:	0f b6 10             	movzbl (%eax),%edx
f0101810:	84 d2                	test   %dl,%dl
f0101812:	75 f1                	jne    f0101805 <strchr+0x17>
f0101814:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101819:	5d                   	pop    %ebp
f010181a:	c3                   	ret    

f010181b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010181b:	55                   	push   %ebp
f010181c:	89 e5                	mov    %esp,%ebp
f010181e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101821:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101825:	0f b6 10             	movzbl (%eax),%edx
f0101828:	84 d2                	test   %dl,%dl
f010182a:	74 18                	je     f0101844 <strfind+0x29>
		if (*s == c)
f010182c:	38 ca                	cmp    %cl,%dl
f010182e:	75 0a                	jne    f010183a <strfind+0x1f>
f0101830:	eb 12                	jmp    f0101844 <strfind+0x29>
f0101832:	38 ca                	cmp    %cl,%dl
f0101834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101838:	74 0a                	je     f0101844 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010183a:	83 c0 01             	add    $0x1,%eax
f010183d:	0f b6 10             	movzbl (%eax),%edx
f0101840:	84 d2                	test   %dl,%dl
f0101842:	75 ee                	jne    f0101832 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101844:	5d                   	pop    %ebp
f0101845:	c3                   	ret    

f0101846 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101846:	55                   	push   %ebp
f0101847:	89 e5                	mov    %esp,%ebp
f0101849:	83 ec 0c             	sub    $0xc,%esp
f010184c:	89 1c 24             	mov    %ebx,(%esp)
f010184f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101853:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101857:	8b 7d 08             	mov    0x8(%ebp),%edi
f010185a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010185d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101860:	85 c9                	test   %ecx,%ecx
f0101862:	74 30                	je     f0101894 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101864:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010186a:	75 25                	jne    f0101891 <memset+0x4b>
f010186c:	f6 c1 03             	test   $0x3,%cl
f010186f:	75 20                	jne    f0101891 <memset+0x4b>
		c &= 0xFF;
f0101871:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101874:	89 d3                	mov    %edx,%ebx
f0101876:	c1 e3 08             	shl    $0x8,%ebx
f0101879:	89 d6                	mov    %edx,%esi
f010187b:	c1 e6 18             	shl    $0x18,%esi
f010187e:	89 d0                	mov    %edx,%eax
f0101880:	c1 e0 10             	shl    $0x10,%eax
f0101883:	09 f0                	or     %esi,%eax
f0101885:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0101887:	09 d8                	or     %ebx,%eax
f0101889:	c1 e9 02             	shr    $0x2,%ecx
f010188c:	fc                   	cld    
f010188d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010188f:	eb 03                	jmp    f0101894 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101891:	fc                   	cld    
f0101892:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101894:	89 f8                	mov    %edi,%eax
f0101896:	8b 1c 24             	mov    (%esp),%ebx
f0101899:	8b 74 24 04          	mov    0x4(%esp),%esi
f010189d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01018a1:	89 ec                	mov    %ebp,%esp
f01018a3:	5d                   	pop    %ebp
f01018a4:	c3                   	ret    

f01018a5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01018a5:	55                   	push   %ebp
f01018a6:	89 e5                	mov    %esp,%ebp
f01018a8:	83 ec 08             	sub    $0x8,%esp
f01018ab:	89 34 24             	mov    %esi,(%esp)
f01018ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01018b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01018b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f01018b8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f01018bb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f01018bd:	39 c6                	cmp    %eax,%esi
f01018bf:	73 35                	jae    f01018f6 <memmove+0x51>
f01018c1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01018c4:	39 d0                	cmp    %edx,%eax
f01018c6:	73 2e                	jae    f01018f6 <memmove+0x51>
		s += n;
		d += n;
f01018c8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01018ca:	f6 c2 03             	test   $0x3,%dl
f01018cd:	75 1b                	jne    f01018ea <memmove+0x45>
f01018cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01018d5:	75 13                	jne    f01018ea <memmove+0x45>
f01018d7:	f6 c1 03             	test   $0x3,%cl
f01018da:	75 0e                	jne    f01018ea <memmove+0x45>
			asm volatile("std; rep movsl\n"
f01018dc:	83 ef 04             	sub    $0x4,%edi
f01018df:	8d 72 fc             	lea    -0x4(%edx),%esi
f01018e2:	c1 e9 02             	shr    $0x2,%ecx
f01018e5:	fd                   	std    
f01018e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01018e8:	eb 09                	jmp    f01018f3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01018ea:	83 ef 01             	sub    $0x1,%edi
f01018ed:	8d 72 ff             	lea    -0x1(%edx),%esi
f01018f0:	fd                   	std    
f01018f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01018f3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01018f4:	eb 20                	jmp    f0101916 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01018f6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01018fc:	75 15                	jne    f0101913 <memmove+0x6e>
f01018fe:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101904:	75 0d                	jne    f0101913 <memmove+0x6e>
f0101906:	f6 c1 03             	test   $0x3,%cl
f0101909:	75 08                	jne    f0101913 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f010190b:	c1 e9 02             	shr    $0x2,%ecx
f010190e:	fc                   	cld    
f010190f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101911:	eb 03                	jmp    f0101916 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101913:	fc                   	cld    
f0101914:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101916:	8b 34 24             	mov    (%esp),%esi
f0101919:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010191d:	89 ec                	mov    %ebp,%esp
f010191f:	5d                   	pop    %ebp
f0101920:	c3                   	ret    

f0101921 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0101921:	55                   	push   %ebp
f0101922:	89 e5                	mov    %esp,%ebp
f0101924:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101927:	8b 45 10             	mov    0x10(%ebp),%eax
f010192a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010192e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101931:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101935:	8b 45 08             	mov    0x8(%ebp),%eax
f0101938:	89 04 24             	mov    %eax,(%esp)
f010193b:	e8 65 ff ff ff       	call   f01018a5 <memmove>
}
f0101940:	c9                   	leave  
f0101941:	c3                   	ret    

f0101942 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101942:	55                   	push   %ebp
f0101943:	89 e5                	mov    %esp,%ebp
f0101945:	57                   	push   %edi
f0101946:	56                   	push   %esi
f0101947:	53                   	push   %ebx
f0101948:	8b 75 08             	mov    0x8(%ebp),%esi
f010194b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010194e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101951:	85 c9                	test   %ecx,%ecx
f0101953:	74 36                	je     f010198b <memcmp+0x49>
		if (*s1 != *s2)
f0101955:	0f b6 06             	movzbl (%esi),%eax
f0101958:	0f b6 1f             	movzbl (%edi),%ebx
f010195b:	38 d8                	cmp    %bl,%al
f010195d:	74 20                	je     f010197f <memcmp+0x3d>
f010195f:	eb 14                	jmp    f0101975 <memcmp+0x33>
f0101961:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0101966:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010196b:	83 c2 01             	add    $0x1,%edx
f010196e:	83 e9 01             	sub    $0x1,%ecx
f0101971:	38 d8                	cmp    %bl,%al
f0101973:	74 12                	je     f0101987 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0101975:	0f b6 c0             	movzbl %al,%eax
f0101978:	0f b6 db             	movzbl %bl,%ebx
f010197b:	29 d8                	sub    %ebx,%eax
f010197d:	eb 11                	jmp    f0101990 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010197f:	83 e9 01             	sub    $0x1,%ecx
f0101982:	ba 00 00 00 00       	mov    $0x0,%edx
f0101987:	85 c9                	test   %ecx,%ecx
f0101989:	75 d6                	jne    f0101961 <memcmp+0x1f>
f010198b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101990:	5b                   	pop    %ebx
f0101991:	5e                   	pop    %esi
f0101992:	5f                   	pop    %edi
f0101993:	5d                   	pop    %ebp
f0101994:	c3                   	ret    

f0101995 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101995:	55                   	push   %ebp
f0101996:	89 e5                	mov    %esp,%ebp
f0101998:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010199b:	89 c2                	mov    %eax,%edx
f010199d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01019a0:	39 d0                	cmp    %edx,%eax
f01019a2:	73 15                	jae    f01019b9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f01019a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f01019a8:	38 08                	cmp    %cl,(%eax)
f01019aa:	75 06                	jne    f01019b2 <memfind+0x1d>
f01019ac:	eb 0b                	jmp    f01019b9 <memfind+0x24>
f01019ae:	38 08                	cmp    %cl,(%eax)
f01019b0:	74 07                	je     f01019b9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01019b2:	83 c0 01             	add    $0x1,%eax
f01019b5:	39 c2                	cmp    %eax,%edx
f01019b7:	77 f5                	ja     f01019ae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01019b9:	5d                   	pop    %ebp
f01019ba:	c3                   	ret    

f01019bb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01019bb:	55                   	push   %ebp
f01019bc:	89 e5                	mov    %esp,%ebp
f01019be:	57                   	push   %edi
f01019bf:	56                   	push   %esi
f01019c0:	53                   	push   %ebx
f01019c1:	83 ec 04             	sub    $0x4,%esp
f01019c4:	8b 55 08             	mov    0x8(%ebp),%edx
f01019c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01019ca:	0f b6 02             	movzbl (%edx),%eax
f01019cd:	3c 20                	cmp    $0x20,%al
f01019cf:	74 04                	je     f01019d5 <strtol+0x1a>
f01019d1:	3c 09                	cmp    $0x9,%al
f01019d3:	75 0e                	jne    f01019e3 <strtol+0x28>
		s++;
f01019d5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01019d8:	0f b6 02             	movzbl (%edx),%eax
f01019db:	3c 20                	cmp    $0x20,%al
f01019dd:	74 f6                	je     f01019d5 <strtol+0x1a>
f01019df:	3c 09                	cmp    $0x9,%al
f01019e1:	74 f2                	je     f01019d5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01019e3:	3c 2b                	cmp    $0x2b,%al
f01019e5:	75 0c                	jne    f01019f3 <strtol+0x38>
		s++;
f01019e7:	83 c2 01             	add    $0x1,%edx
f01019ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01019f1:	eb 15                	jmp    f0101a08 <strtol+0x4d>
	else if (*s == '-')
f01019f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01019fa:	3c 2d                	cmp    $0x2d,%al
f01019fc:	75 0a                	jne    f0101a08 <strtol+0x4d>
		s++, neg = 1;
f01019fe:	83 c2 01             	add    $0x1,%edx
f0101a01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101a08:	85 db                	test   %ebx,%ebx
f0101a0a:	0f 94 c0             	sete   %al
f0101a0d:	74 05                	je     f0101a14 <strtol+0x59>
f0101a0f:	83 fb 10             	cmp    $0x10,%ebx
f0101a12:	75 18                	jne    f0101a2c <strtol+0x71>
f0101a14:	80 3a 30             	cmpb   $0x30,(%edx)
f0101a17:	75 13                	jne    f0101a2c <strtol+0x71>
f0101a19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101a1d:	8d 76 00             	lea    0x0(%esi),%esi
f0101a20:	75 0a                	jne    f0101a2c <strtol+0x71>
		s += 2, base = 16;
f0101a22:	83 c2 02             	add    $0x2,%edx
f0101a25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101a2a:	eb 15                	jmp    f0101a41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101a2c:	84 c0                	test   %al,%al
f0101a2e:	66 90                	xchg   %ax,%ax
f0101a30:	74 0f                	je     f0101a41 <strtol+0x86>
f0101a32:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101a37:	80 3a 30             	cmpb   $0x30,(%edx)
f0101a3a:	75 05                	jne    f0101a41 <strtol+0x86>
		s++, base = 8;
f0101a3c:	83 c2 01             	add    $0x1,%edx
f0101a3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101a41:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101a48:	0f b6 0a             	movzbl (%edx),%ecx
f0101a4b:	89 cf                	mov    %ecx,%edi
f0101a4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101a50:	80 fb 09             	cmp    $0x9,%bl
f0101a53:	77 08                	ja     f0101a5d <strtol+0xa2>
			dig = *s - '0';
f0101a55:	0f be c9             	movsbl %cl,%ecx
f0101a58:	83 e9 30             	sub    $0x30,%ecx
f0101a5b:	eb 1e                	jmp    f0101a7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f0101a5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101a60:	80 fb 19             	cmp    $0x19,%bl
f0101a63:	77 08                	ja     f0101a6d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0101a65:	0f be c9             	movsbl %cl,%ecx
f0101a68:	83 e9 57             	sub    $0x57,%ecx
f0101a6b:	eb 0e                	jmp    f0101a7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f0101a6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101a70:	80 fb 19             	cmp    $0x19,%bl
f0101a73:	77 15                	ja     f0101a8a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0101a75:	0f be c9             	movsbl %cl,%ecx
f0101a78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101a7b:	39 f1                	cmp    %esi,%ecx
f0101a7d:	7d 0b                	jge    f0101a8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f0101a7f:	83 c2 01             	add    $0x1,%edx
f0101a82:	0f af c6             	imul   %esi,%eax
f0101a85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101a88:	eb be                	jmp    f0101a48 <strtol+0x8d>
f0101a8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0101a8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101a90:	74 05                	je     f0101a97 <strtol+0xdc>
		*endptr = (char *) s;
f0101a92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101a95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101a97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0101a9b:	74 04                	je     f0101aa1 <strtol+0xe6>
f0101a9d:	89 c8                	mov    %ecx,%eax
f0101a9f:	f7 d8                	neg    %eax
}
f0101aa1:	83 c4 04             	add    $0x4,%esp
f0101aa4:	5b                   	pop    %ebx
f0101aa5:	5e                   	pop    %esi
f0101aa6:	5f                   	pop    %edi
f0101aa7:	5d                   	pop    %ebp
f0101aa8:	c3                   	ret    
f0101aa9:	00 00                	add    %al,(%eax)
f0101aab:	00 00                	add    %al,(%eax)
f0101aad:	00 00                	add    %al,(%eax)
	...

f0101ab0 <__udivdi3>:
f0101ab0:	55                   	push   %ebp
f0101ab1:	89 e5                	mov    %esp,%ebp
f0101ab3:	57                   	push   %edi
f0101ab4:	56                   	push   %esi
f0101ab5:	83 ec 10             	sub    $0x10,%esp
f0101ab8:	8b 45 14             	mov    0x14(%ebp),%eax
f0101abb:	8b 55 08             	mov    0x8(%ebp),%edx
f0101abe:	8b 75 10             	mov    0x10(%ebp),%esi
f0101ac1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101ac4:	85 c0                	test   %eax,%eax
f0101ac6:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0101ac9:	75 35                	jne    f0101b00 <__udivdi3+0x50>
f0101acb:	39 fe                	cmp    %edi,%esi
f0101acd:	77 61                	ja     f0101b30 <__udivdi3+0x80>
f0101acf:	85 f6                	test   %esi,%esi
f0101ad1:	75 0b                	jne    f0101ade <__udivdi3+0x2e>
f0101ad3:	b8 01 00 00 00       	mov    $0x1,%eax
f0101ad8:	31 d2                	xor    %edx,%edx
f0101ada:	f7 f6                	div    %esi
f0101adc:	89 c6                	mov    %eax,%esi
f0101ade:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0101ae1:	31 d2                	xor    %edx,%edx
f0101ae3:	89 f8                	mov    %edi,%eax
f0101ae5:	f7 f6                	div    %esi
f0101ae7:	89 c7                	mov    %eax,%edi
f0101ae9:	89 c8                	mov    %ecx,%eax
f0101aeb:	f7 f6                	div    %esi
f0101aed:	89 c1                	mov    %eax,%ecx
f0101aef:	89 fa                	mov    %edi,%edx
f0101af1:	89 c8                	mov    %ecx,%eax
f0101af3:	83 c4 10             	add    $0x10,%esp
f0101af6:	5e                   	pop    %esi
f0101af7:	5f                   	pop    %edi
f0101af8:	5d                   	pop    %ebp
f0101af9:	c3                   	ret    
f0101afa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b00:	39 f8                	cmp    %edi,%eax
f0101b02:	77 1c                	ja     f0101b20 <__udivdi3+0x70>
f0101b04:	0f bd d0             	bsr    %eax,%edx
f0101b07:	83 f2 1f             	xor    $0x1f,%edx
f0101b0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101b0d:	75 39                	jne    f0101b48 <__udivdi3+0x98>
f0101b0f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0101b12:	0f 86 a0 00 00 00    	jbe    f0101bb8 <__udivdi3+0x108>
f0101b18:	39 f8                	cmp    %edi,%eax
f0101b1a:	0f 82 98 00 00 00    	jb     f0101bb8 <__udivdi3+0x108>
f0101b20:	31 ff                	xor    %edi,%edi
f0101b22:	31 c9                	xor    %ecx,%ecx
f0101b24:	89 c8                	mov    %ecx,%eax
f0101b26:	89 fa                	mov    %edi,%edx
f0101b28:	83 c4 10             	add    $0x10,%esp
f0101b2b:	5e                   	pop    %esi
f0101b2c:	5f                   	pop    %edi
f0101b2d:	5d                   	pop    %ebp
f0101b2e:	c3                   	ret    
f0101b2f:	90                   	nop
f0101b30:	89 d1                	mov    %edx,%ecx
f0101b32:	89 fa                	mov    %edi,%edx
f0101b34:	89 c8                	mov    %ecx,%eax
f0101b36:	31 ff                	xor    %edi,%edi
f0101b38:	f7 f6                	div    %esi
f0101b3a:	89 c1                	mov    %eax,%ecx
f0101b3c:	89 fa                	mov    %edi,%edx
f0101b3e:	89 c8                	mov    %ecx,%eax
f0101b40:	83 c4 10             	add    $0x10,%esp
f0101b43:	5e                   	pop    %esi
f0101b44:	5f                   	pop    %edi
f0101b45:	5d                   	pop    %ebp
f0101b46:	c3                   	ret    
f0101b47:	90                   	nop
f0101b48:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101b4c:	89 f2                	mov    %esi,%edx
f0101b4e:	d3 e0                	shl    %cl,%eax
f0101b50:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101b53:	b8 20 00 00 00       	mov    $0x20,%eax
f0101b58:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0101b5b:	89 c1                	mov    %eax,%ecx
f0101b5d:	d3 ea                	shr    %cl,%edx
f0101b5f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101b63:	0b 55 ec             	or     -0x14(%ebp),%edx
f0101b66:	d3 e6                	shl    %cl,%esi
f0101b68:	89 c1                	mov    %eax,%ecx
f0101b6a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0101b6d:	89 fe                	mov    %edi,%esi
f0101b6f:	d3 ee                	shr    %cl,%esi
f0101b71:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101b75:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101b78:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101b7b:	d3 e7                	shl    %cl,%edi
f0101b7d:	89 c1                	mov    %eax,%ecx
f0101b7f:	d3 ea                	shr    %cl,%edx
f0101b81:	09 d7                	or     %edx,%edi
f0101b83:	89 f2                	mov    %esi,%edx
f0101b85:	89 f8                	mov    %edi,%eax
f0101b87:	f7 75 ec             	divl   -0x14(%ebp)
f0101b8a:	89 d6                	mov    %edx,%esi
f0101b8c:	89 c7                	mov    %eax,%edi
f0101b8e:	f7 65 e8             	mull   -0x18(%ebp)
f0101b91:	39 d6                	cmp    %edx,%esi
f0101b93:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101b96:	72 30                	jb     f0101bc8 <__udivdi3+0x118>
f0101b98:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101b9b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101b9f:	d3 e2                	shl    %cl,%edx
f0101ba1:	39 c2                	cmp    %eax,%edx
f0101ba3:	73 05                	jae    f0101baa <__udivdi3+0xfa>
f0101ba5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101ba8:	74 1e                	je     f0101bc8 <__udivdi3+0x118>
f0101baa:	89 f9                	mov    %edi,%ecx
f0101bac:	31 ff                	xor    %edi,%edi
f0101bae:	e9 71 ff ff ff       	jmp    f0101b24 <__udivdi3+0x74>
f0101bb3:	90                   	nop
f0101bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101bb8:	31 ff                	xor    %edi,%edi
f0101bba:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101bbf:	e9 60 ff ff ff       	jmp    f0101b24 <__udivdi3+0x74>
f0101bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101bc8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0101bcb:	31 ff                	xor    %edi,%edi
f0101bcd:	89 c8                	mov    %ecx,%eax
f0101bcf:	89 fa                	mov    %edi,%edx
f0101bd1:	83 c4 10             	add    $0x10,%esp
f0101bd4:	5e                   	pop    %esi
f0101bd5:	5f                   	pop    %edi
f0101bd6:	5d                   	pop    %ebp
f0101bd7:	c3                   	ret    
	...

f0101be0 <__umoddi3>:
f0101be0:	55                   	push   %ebp
f0101be1:	89 e5                	mov    %esp,%ebp
f0101be3:	57                   	push   %edi
f0101be4:	56                   	push   %esi
f0101be5:	83 ec 20             	sub    $0x20,%esp
f0101be8:	8b 55 14             	mov    0x14(%ebp),%edx
f0101beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101bee:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101bf1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101bf4:	85 d2                	test   %edx,%edx
f0101bf6:	89 c8                	mov    %ecx,%eax
f0101bf8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0101bfb:	75 13                	jne    f0101c10 <__umoddi3+0x30>
f0101bfd:	39 f7                	cmp    %esi,%edi
f0101bff:	76 3f                	jbe    f0101c40 <__umoddi3+0x60>
f0101c01:	89 f2                	mov    %esi,%edx
f0101c03:	f7 f7                	div    %edi
f0101c05:	89 d0                	mov    %edx,%eax
f0101c07:	31 d2                	xor    %edx,%edx
f0101c09:	83 c4 20             	add    $0x20,%esp
f0101c0c:	5e                   	pop    %esi
f0101c0d:	5f                   	pop    %edi
f0101c0e:	5d                   	pop    %ebp
f0101c0f:	c3                   	ret    
f0101c10:	39 f2                	cmp    %esi,%edx
f0101c12:	77 4c                	ja     f0101c60 <__umoddi3+0x80>
f0101c14:	0f bd ca             	bsr    %edx,%ecx
f0101c17:	83 f1 1f             	xor    $0x1f,%ecx
f0101c1a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101c1d:	75 51                	jne    f0101c70 <__umoddi3+0x90>
f0101c1f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0101c22:	0f 87 e0 00 00 00    	ja     f0101d08 <__umoddi3+0x128>
f0101c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c2b:	29 f8                	sub    %edi,%eax
f0101c2d:	19 d6                	sbb    %edx,%esi
f0101c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c35:	89 f2                	mov    %esi,%edx
f0101c37:	83 c4 20             	add    $0x20,%esp
f0101c3a:	5e                   	pop    %esi
f0101c3b:	5f                   	pop    %edi
f0101c3c:	5d                   	pop    %ebp
f0101c3d:	c3                   	ret    
f0101c3e:	66 90                	xchg   %ax,%ax
f0101c40:	85 ff                	test   %edi,%edi
f0101c42:	75 0b                	jne    f0101c4f <__umoddi3+0x6f>
f0101c44:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c49:	31 d2                	xor    %edx,%edx
f0101c4b:	f7 f7                	div    %edi
f0101c4d:	89 c7                	mov    %eax,%edi
f0101c4f:	89 f0                	mov    %esi,%eax
f0101c51:	31 d2                	xor    %edx,%edx
f0101c53:	f7 f7                	div    %edi
f0101c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c58:	f7 f7                	div    %edi
f0101c5a:	eb a9                	jmp    f0101c05 <__umoddi3+0x25>
f0101c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101c60:	89 c8                	mov    %ecx,%eax
f0101c62:	89 f2                	mov    %esi,%edx
f0101c64:	83 c4 20             	add    $0x20,%esp
f0101c67:	5e                   	pop    %esi
f0101c68:	5f                   	pop    %edi
f0101c69:	5d                   	pop    %ebp
f0101c6a:	c3                   	ret    
f0101c6b:	90                   	nop
f0101c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101c70:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101c74:	d3 e2                	shl    %cl,%edx
f0101c76:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101c79:	ba 20 00 00 00       	mov    $0x20,%edx
f0101c7e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101c81:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101c84:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101c88:	89 fa                	mov    %edi,%edx
f0101c8a:	d3 ea                	shr    %cl,%edx
f0101c8c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101c90:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101c93:	d3 e7                	shl    %cl,%edi
f0101c95:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101c99:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101c9c:	89 f2                	mov    %esi,%edx
f0101c9e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0101ca1:	89 c7                	mov    %eax,%edi
f0101ca3:	d3 ea                	shr    %cl,%edx
f0101ca5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101ca9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101cac:	89 c2                	mov    %eax,%edx
f0101cae:	d3 e6                	shl    %cl,%esi
f0101cb0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101cb4:	d3 ea                	shr    %cl,%edx
f0101cb6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101cba:	09 d6                	or     %edx,%esi
f0101cbc:	89 f0                	mov    %esi,%eax
f0101cbe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101cc1:	d3 e7                	shl    %cl,%edi
f0101cc3:	89 f2                	mov    %esi,%edx
f0101cc5:	f7 75 f4             	divl   -0xc(%ebp)
f0101cc8:	89 d6                	mov    %edx,%esi
f0101cca:	f7 65 e8             	mull   -0x18(%ebp)
f0101ccd:	39 d6                	cmp    %edx,%esi
f0101ccf:	72 2b                	jb     f0101cfc <__umoddi3+0x11c>
f0101cd1:	39 c7                	cmp    %eax,%edi
f0101cd3:	72 23                	jb     f0101cf8 <__umoddi3+0x118>
f0101cd5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101cd9:	29 c7                	sub    %eax,%edi
f0101cdb:	19 d6                	sbb    %edx,%esi
f0101cdd:	89 f0                	mov    %esi,%eax
f0101cdf:	89 f2                	mov    %esi,%edx
f0101ce1:	d3 ef                	shr    %cl,%edi
f0101ce3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101ce7:	d3 e0                	shl    %cl,%eax
f0101ce9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101ced:	09 f8                	or     %edi,%eax
f0101cef:	d3 ea                	shr    %cl,%edx
f0101cf1:	83 c4 20             	add    $0x20,%esp
f0101cf4:	5e                   	pop    %esi
f0101cf5:	5f                   	pop    %edi
f0101cf6:	5d                   	pop    %ebp
f0101cf7:	c3                   	ret    
f0101cf8:	39 d6                	cmp    %edx,%esi
f0101cfa:	75 d9                	jne    f0101cd5 <__umoddi3+0xf5>
f0101cfc:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0101cff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0101d02:	eb d1                	jmp    f0101cd5 <__umoddi3+0xf5>
f0101d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101d08:	39 f2                	cmp    %esi,%edx
f0101d0a:	0f 82 18 ff ff ff    	jb     f0101c28 <__umoddi3+0x48>
f0101d10:	e9 1d ff ff ff       	jmp    f0101c32 <__umoddi3+0x52>
