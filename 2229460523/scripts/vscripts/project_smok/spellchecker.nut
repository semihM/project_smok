/***************\
* SPELL CHECKER *
\***************/
::SpellChecker <- {}

::SpellChecker.DistanceMax <- 3
::SpellChecker.DisplayMax <- 5

::SpellChecker.LevenshteinDist <- function(s1,s2)
{
	function min(x,y,z)
	{
		return x<=y ? (x<=z ? x : z) 
					: (y<=z ? y : z)
	}

	local dist = {}
	local m = s1.len()
	local n = s2.len()

	for(local i=0;i<=m;i++)
	{
		dist[i] <- {}
		for(local j=0;j<=n;j++)
		{
			dist[i][j] <- 0
		}
	}

	for(local i=1;i<=m;i++)
	{
		dist[i][0] <- i
	}
	for(local j=1;j<=n;j++)
	{
		dist[0][j] <- j
	}

	for(local j=1;j<=n;j++)
	{
		for(local i=1;i<=m;i++)
		{
			local cost = 0
			if(s1[i-1] != s2[j-1])
				cost = 1
			dist[i][j] = min(dist[i-1][j] + 1, dist[i][j-1] + 1, dist[i-1][j-1] + cost)
		}
	}

	return dist[m][n]
}

// TO-DO: Make this a class
// TO-DO: Cache checked words
::SpellChecker.GetBestMatches <- function(word,lookuptbl)
{
	local result = {}
	local backup = {}
	foreach(w,val in lookuptbl)
	{	
		local dist = ::SpellChecker.LevenshteinDist(word,w)
		
		if(dist <= ::SpellChecker.DistanceMax)
		{
			if(dist in result)
				result[dist].append(w)
			else
				result[dist] <- [w]
		}
		else
		{
			if(backup.len() == 0)
			{
				backup[-1] <- dist
				backup[dist] <- w
			}
			else
			{
				foreach(d,ws in backup)
				{
					if(d > dist)
					{
						backup[-1] <- dist
						backup[dist] <- w
						delete backup[d]
						break;
					}
				}
			}
		}
	}

	if(result.len() == 0 && backup.len() != 0)
	{
		return backup;
	}
	return result;
}

::SpellChecker.PrintBestMatches <- function(player,word,lookuptbl,typ="command")
{	
	local matches = ::SpellChecker.GetBestMatches(word,lookuptbl)
	if(matches.len() == 0)
	{
		ClientPrint(player,3,"Unknown "+typ+": "+word);
		return;
	}
	else if(-1 in matches)
	{
		ClientPrint(player,3,"Unknown "+typ+": "+word+". Did you mean"+COLOR_ORANGE+" "+matches[matches[-1]]);
	}
	else
	{	
		ClientPrint(player,3,"Unknown "+typ+", did you mean one of the words below?")
	
		local matchesleft = ::SpellChecker.DisplayMax
		local m = 1;

		for(local dist=1;dist<=::SpellChecker.DistanceMax;dist++)
		{
			if(matchesleft == 0)
				break;
		
			if(!(dist in matches))
				continue;
		
			local mlen = matches[dist].len();
			if(mlen<=matchesleft)
			{
				foreach(i,word in matches[dist].slice(0,mlen))
				{
					ClientPrint(player,3,COLOR_ORANGE + m + ". " + COLOR_DEFAULT + word);
					m += 1;
				}
				matchesleft -= mlen;
			}
			else
			{
				foreach(i,word in matches[dist].slice(0,matchesleft))
				{
					ClientPrint(player,3,COLOR_ORANGE + m + ". " + COLOR_DEFAULT + word);
					m += 1;
				}
				matchesleft = 0
			}
		}
	}
}