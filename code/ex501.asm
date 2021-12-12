datarea		segment
grade		dw			50 dup(?)
rank		dw			50 dup(?)
count		dw			?
mess1		db			'Grade? $'
mess2		db				13, 10, 'Input Error!', 13, 10, '$'
mess3		db			'Rank: $'
datarea		ends


prognam		segment

main		proc		far
			assume	cs: prognam, ds: datarea
			
start:

			push		ds
			sub			ax, ax
			push		ax
			
			mov			ax, datarea
			mov			ds, ax
			
			call		input
			call		rankp
			call		output
			ret
main		endp

input		proc		near
			lea			dx, mess1
			mov			ah, 09
			int			21h
			
			mov			si, 0
			mov			count, 0
enter:
			call		decibin
			inc			count
			cmp			dl, ','
			je			store
			cmp			dl, 13
			je			exit2
			jne			error
store:		
			mov			grade[si], bx
			add			si, 2
			jmp			enter
error:
			lea			dx, mess2
			mov			ah, 09
			int			21h
exit2:
			mov			grade[si], bx
			call		crlf
			ret
input		endp

rankp		proc		near
			mov			di, count
			mov			bx, 0
loop1:
			mov			ax, grade[bx]
			mov			WORD ptr rank[bx], 0
			mov			cx, count
			lea			si, grade
next:
			cmp			ax, [si]
			jg			no_count
			inc			WORD ptr rank[bx]
no_count:
			add			si, 2
			loop		next
			add			bx, 2
			dec			di
			jne			loop1
			ret
rankp		endp

output		proc		near
			lea			dx, mess3
			mov			ah, 09
			int			21h
			
			mov			si, 0
			mov			di, count
next1:
			mov			bx, rank[si]
			call		binidec
			mov			dl, ','
			mov			ah, 02
			int			21h
			add			si, 2
			dec			di
			jne			next1
			call		crlf
			ret
output		endp

decibin		proc		near
			mov			bx, 0
newchar:
			mov			ah, 1
			int			21h
			mov			dl, al
			sub			al, 30h
			jl			exit1
			cmp			al, 9d
			jg			exit1
			cbw
			
			xchg		ax, bx
			mov			cx, 10d
			mul			cx
			xchg		ax, bx
			
			add			bx, ax
			jmp			newchar
exit1:		ret
decibin		endp

binidec		proc		near
			push		bx
			push		cx
			push		si
			push		di
			mov			cx, 100d
			call		dec_div
			mov			cx, 10d
			call		dec_div
			mov			cx, 1d
			call		dec_div
			pop			di
			pop			si
			pop			cx
			pop			bx
			ret
binidec		endp

dec_div		proc		near
			push		ax
			push		dx
			mov			ax, bx
			mov			dx, 0
			div			cx
			mov			bx,dx
			mov			dl, al
			
			add			dl, 30h
			mov			ah, 02h
			int			21h
			pop			dx
			pop			ax
			ret
dec_div		endp

crlf		proc		near
			mov			dl, 0ah
			mov			ah, 02h
			int			21h
			
			mov			dl, 0dh
			mov			ah, 02h
			int			21h
			
			ret
crlf		endp

prognam		ends

			end			start