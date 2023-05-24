require 'ruby2d'

# Anger fönstrets titel och storlek
set title: 'Turals Stacker Spel'
grid_size = 40
grid_color = Color.new('#222222')
block_color = Color.new(['red', 'green', 'purple'].sample)
höjd = 16
bredd = 7


set height: höjd * grid_size
set width: bredd * grid_size

# Start meny koden, skapar en text som visas överst på skärmen.
start_text1 = Text.new('TURALS STACKER', size: 20, x:60, y:20)
start_text2 = Text.new('TRYCK "a" FÖR ATT STARTA SPELET!', x: 10, y: 60, size: 15, color: 'white')


# Variabel för att hålla koll på om spelet har startat eller inte. 
# Börjar inledningsvis med "false", då spelet inte har börjat.
game_started = false

# Spel koden, med dess egenskaper som riktning och hastighet.
current_line = höjd - 1
current_direction = :right
speed = 4
record = 0

#Definierar två variabler för de aktiva respektive frysta klossar.
frozen_squares = {}
active_squares = (0..4).map do |index|
  Square.new(
    x: grid_size * index,
    y: grid_size * current_line,
    size: grid_size,
    color: block_color
  )
end

# Uppdateringsloop som beskriver om spelet har startat eller slutat.
update do
  if active_squares.empty?
    # Ett meddelande som visas, när spelet är över.
    Text.new('Spelet är över!', size: 30, x: 50, y: 80, z: 2)
    Text.new("Du fick: #{record}", size: 30, x: 50, y: 120, z: 2)
  else
    # Kör kodblocket om antalet frames är jämnt delbart med kvoten av 60 dividerat med hastigheten.
    # Innebär att koden kommer att köras med en frekvens som beror på värdet av speed.
    # Till exempel, om hastigheten är tilldelad värdet 2, kommer koden att köras varje 30 bilder(frames) (60 / 2),
    # Om hastigheten är tilldelad 1, kommer koden att köras varje 60 bilder(frames) (60 / 1).
    if Window.frames % (60 / speed) == 0
      case current_direction
      when :right
        # Flyttar aktiva rutor åt höger.
        active_squares.each { |square| square.x += grid_size }
        if active_squares.last.x + active_squares.last.width >= Window.width
          current_direction = :left
        end
      when :left
        # När högerkanten är nådd, byter den rörelseriktning åt vänster. 
        active_squares.each { |square| square.x -= grid_size }
        if active_squares.first.x <= 0
          # När vänsterkanten är nådd, byter den rörelseriktning åt höger.
          current_direction = :right
        end
      end
    end
  end
end


# Definierar vad som sker när en viss tangent trycks ned, i detta fallet tangenten 'a'.
# Kallas även för en händelselyssnare då den aktiverar eller deaktiverar olika egenskaper som färg och text.
on :key_down do |event|
  if event.key == 'a' && !game_started
    start_text1.remove
    start_text2.remove
    
    # X:axeln:
    (0..Window.width).step(grid_size).each do |x|
        Line.new(x1: x, x2: x, y1: 0, y2: Window.height, width: 2, color: grid_color, z: 1)
    end
    
    # Y:axeln:
    (0..Window.height).step(grid_size).each do |y|
        Line.new(x1: 0, x2: Window.width, y1: y, y2: y, width: 2, color: grid_color, z: 1)
    end
    game_started = true
  end
end

# Definierar vad som sker när en viss tangent trycks ned, i detta fallet tangenten 'space'
# Kallas även för en händelselyssnare då den aktiverar spelets funktioner och börjar stapla blocken.
on :key_down do |event|
  # Variabeln definierat att om tangenten 'space' är nedtryckt och spelet är igång ska den utföra olika funktioner.
    if event.key == 'space' && game_started
        current_line -= 1
        speed += 1
        
        active_squares.each do |active_square|
            if current_line == höjd - 2 || frozen_squares.has_key?("#{active_square.x}, #{active_square.y + grid_size}")
            #Lagrar de frusna rutorna i hakparanteset.
            frozen_squares["#{active_square.x}, #{active_square.y}"] = Square.new(
            x: active_square.x,
            y: active_square.y,
            color: block_color,
            size: grid_size
            )
        end
        end

        # Tar bort de aktiva rutorna från skärmen
        active_squares.each(&:remove)
        active_squares = []

        (0..bredd).each do |index|
        x = grid_size * index
        y = grid_size * current_line

        if frozen_squares.has_key?("#{x}, #{y + grid_size}")
          # Skapar nya aktiva rutor baserat på frusna rutor.
            active_squares.push(Square.new(
            x: x,
            y: y,
            color: block_color,
            size: grid_size
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
Detta projekt har jag gjort stacker spelet, ett spel som består av ett rutnät där spelaren ->
ska stapla block ovanpå varandra. Blocken rör sig från ena sidan till den andra och spelaren måste trycka på tangenten i 
rätt tidpunkt för att placera blocket ovanpå det föregående blocket. Om spelet missar och blocket inte hamnar ->
ovanpå de föregående blocket, avslutas spelet.

Uppbyggnaden av spelet:
Koden börjar med att konfigurera fönstret och skapa textobjekt för spelets titel och instruktioner. -> 
När spelaren trycker på tangenten 'a' startas spelet.

I spelloopen uppdateras positionen för de aktiva blocken och rutnätet. Om spelet är över visas slutmeddelanden och spelet stängs av, 
annars fortsätter spelet och rör sig successivt uppåt på rutnätet. Rekordet uppdateras med antalet frusna rutor, 
vilket motsvarar hur långt upp på skärmen klossarna har uppnått.
=end
