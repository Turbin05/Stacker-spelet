require 'ruby2d'

# Anger fönstrets titel och storlek
set title: 'Turals Stacker Spel'
GRID_SIZE = 40
GRID_COLOR = Color.new('#222222')
BLOCK_COLOR = Color.new(['red', 'green', 'purple'].sample)
Height = 16
Width = 7


set height: Height * GRID_SIZE
set width: Width * GRID_SIZE

# Start meny koden, skapar en text so visas överst på skärmen.
start_text1 = Text.new('TURALS STACKER', size: 20, x:60, y:20)
start_text2 = Text.new('TRYCK "a" FÖR ATT STARTA SPELET!', x: 10, y: 60, size: 15, color: 'white')


# Variabel för att hålla koll på om spelet har startat eller inte. 
#Börjar inledningsvis med "false", då spelet ej har börjat.
game_started = false

# Spel koden, med dess egenskaper som riktning och hastighet.
current_line = Height - 1
current_direction = :right
speed = 4
record = 0

frozen_squares = {}
active_squares = (0..4).map do |index|
  Square.new(
    x: GRID_SIZE * index,
    y: GRID_SIZE * current_line,
    size: GRID_SIZE,
    color: BLOCK_COLOR
  )
end

# Uppdateringsloop som säger om spelet är slut eller har startat.
update do
  if active_squares.empty?
    # Ett meddelande som visas, när spelet är över.
    Text.new('Spelet är över!', size: 30, x: 50, y: 80, z: 2)
    Text.new("Du fick: #{record}", size: 30, x: 50, y: 120, z: 2)
  else
    if Window.frames % (60 / speed) == 0
      case current_direction
      when :right
        # Flyttar aktiva rutor åt höger.
        active_squares.each { |square| square.x += GRID_SIZE }
        if active_squares.last.x + active_squares.last.width >= Window.width
          current_direction = :left
        end
      when :left
        # När högerkanten är nådd, byter den rörelseriktning åt vänster. 
        active_squares.each { |square| square.x -= GRID_SIZE }
        if active_squares.first.x <= 0
          # När vänsterkanten är nådd, byter den rörelseriktning åt vänster.
          current_direction = :right
        end
      end
    end
  end
end


# Definierar vad som sker när en viss tangent trycks ned, i detta fallet tangenten 'a'
# Kallas även för en händelselyssnare ->
# då den aktiverar eller deaktiverar olika egenskaper som färg och text.
on :key_down do |event|
  if event.key == 'a' && !game_started
    start_text1.remove
    start_text2.remove
    
    # X:axeln:
    (0..Window.width).step(GRID_SIZE).each do |x|
        Line.new(x1: x, x2: x, y1: 0, y2: Window.height, width: 2, color: GRID_COLOR, z: 1)
    end
    
    # Y:axeln:
    (0..Window.height).step(GRID_SIZE).each do |y|
        Line.new(x1: 0, x2: Window.width, y1: y, y2: y, width: 2, color: GRID_COLOR, z: 1)
    end
    game_started = true
  end
end

# Definierar vad som sker när en viss tangent trycks ned, i detta fallet tangenten 'space'
# Kallas även för en händelselyssnare ->
# då den aktiverar spelets funktioner och börjar stapla blockarna
on :key_down do |event|
  # Variabeln definierat att om tangenten 'space' är nedtryckt och spelet är igång ska den utföra olika funktioner.
    if event.key == 'space' && game_started
        current_line -= 1
        speed += 1
        
        active_squares.each do |active_square|
            if current_line == Height - 2 || frozen_squares.has_key?("#{active_square.x}, #{active_square.y + GRID_SIZE}")
            #Lagrar de frusna rutorna i hakparanteset.
            frozen_squares["#{active_square.x}, #{active_square.y}"] = Square.new(
            x: active_square.x,
            y: active_square.y,
            color: BLOCK_COLOR,
            size: GRID_SIZE
            )
        end
        end

        # Tar bort de aktiva rutorna från skärmen
        active_squares.each(&:remove)
        active_squares = []

        (0..Width).each do |index|
        x = GRID_SIZE * index
        y = GRID_SIZE * current_line

        if frozen_squares.has_key?("#{x}, #{y + GRID_SIZE}")
          # Skapar nya aktiva rutor baserat på frusna rutor.
            active_squares.push(Square.new(
            x: x,
            y: y,
            color: BLOCK_COLOR,
            size: GRID_SIZE
            ))
        end
    end
    # Uppdaterar rekordet med antalet frusna rutor
    record = frozen_squares.size
    end
end
# Visar fönstret och startar igång koden som resulterar spelet!

show

=begin
Detta projekt har jag gjort stacker spelet, ett spel som består av rutnät där spelaren ->
ska stapla block ovanpå varandra. Blocken rör sig från ena sidan till den andra och spelaren måste trycka på tangetent i 
rätt tidpunkt för att placera blocket ovanpå det föregående blocket. Om spelet missar och blocket inte hamnar ->
ovanpå föregående block, avslutas spelet.

Uppbyggnaden av spelet:
Det börjar med att konfigurera fönstret och skapa textobjekt för spelets titel och instruktioner. -> 
När spelaren trycker på 'a' startar spelet.

I spelet loop uppdateras positionen för de aktiva blocken och rutnätet. Om spelet är över visas slutmeddelanden och spelet stängs av, 
annars fortsätter spelet och rör sig successivt uppåt på rutnätet. Rekordet uppdateras med antalet frusna rutor, 
vilket motsvarar hur långt upp på skärmen klossarna har uppnått.

=end
