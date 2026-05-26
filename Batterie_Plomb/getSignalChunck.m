function [chunkV, chunkI, chunkT, chunckStart] = getSignalChunck(v, i, t, samplingFreq, dschI, AhStep, chunckNr, lengthChunk)
    samplesToSkip = round(AhStep * 3600 * samplingFreq / dschI);
    chunckStart = (chunckNr - 1) * (lengthChunk + samplesToSkip) + 1;
    
    chunckEnd = chunckStart + lengthChunk - 1;
    
    % Protection contre le dépassement d'index
    if chunckEnd > length(v)
        error('Chunk %d dépasse la longueur du signal (%d > %d)', chunckNr, chunckEnd, length(v));
    end
    
    chunkV = v(chunckStart:chunckEnd);
    chunkI = i(chunckStart:chunckEnd);
    chunkT = t(chunckStart:chunckEnd);
end 