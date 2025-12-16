//
//  NewRecordMessages.swift
//  LaVideoLaPlusVue
//
//  Created by Assistant on 27/10/2025.
//

import Foundation

/**
 * Gestionnaire de messages satiriques et humoristiques pour les nouveaux records.
 * Les messages deviennent progressivement plus impressionnés (mais toujours avec humour)
 * à mesure que le score augmente.
 */
struct NewRecordMessages {
    
    /**
     * Retourne un message satirique adapté au score pour un nouveau record.
     * - Parameter score: Le score du nouveau record
     * - Returns: Un message humoristique
     */
    static func getMessage(for score: Int) -> String {
        switch score {
        case 1:
            return messages1.randomElement() ?? "Nouveau Record !"
        case 2:
            return messages2.randomElement() ?? "Nouveau Record !"
        case 3:
            return messages3.randomElement() ?? "Nouveau Record !"
        case 4...5:
            return messages4to5.randomElement() ?? "Nouveau Record !"
        case 6...9:
            return messages6to8.randomElement() ?? "Nouveau Record !"
        case 10...12:
            return messages9to12.randomElement() ?? "Nouveau Record !"
        case 13...15:
            return messages13to15.randomElement() ?? "Nouveau Record !"
        case 16...18:
            return messages16to18.randomElement() ?? "Nouveau Record !"
        case 19...20:
            return messages19to20.randomElement() ?? "Nouveau Record !"
        case 21...25:
            return messages21to25.randomElement() ?? "Nouveau Record !"
        case 26...30:
            return messages26to30.randomElement() ?? "Nouveau Record !"
        default:
            return messages30plus.randomElement() ?? "Nouveau Record !"
        }
    }
    
    // MARK: - Messages par niveau de score
    
    private static let messages1 = [
        "Waouh... 1 point ! C'est un début... enfin je crois ?",
        "Nouveau record : 1 ! Au moins tu peux pas faire pire !",
        "1 point ! T'as cliqué exprès ou c'était un accident ?",
        "Record battu ! Bon ok, c'était pas dur...",
        "1 vidéo reconnue ! T'es sûr que tu regardes YouTube ?",
        "Félicitations ! Tu viens de découvrir le jeu !",
        "1 point... C'est mieux que 0 ! (à peine)"
    ]
    
    private static let messages2 = [
        "Nouveau record : 2 ! Tu progresses... très lentement.",
        "2 vidéos ! Tu commences à comprendre le principe !",
        "2 points ! À ce rythme, le Hall of Fame c'est pour 2035.",
        "Record explosé ! Bon ... 2, mais quand même !"
    ]
    
    private static let messages3 = [
        "3 points ! Ça devient sérieux... ou pas.",
        "Nouveau record ! Tu maitrises presque les bases !",
        "3 vidéos reconnues ! Tu regardes vraiment YouTube finalement !",
        "Record personnel : 3 ! C'est déjà mieux que la moyenne... de tes scores."
    ]
    
    private static let messages4to5 = [
        "Pas mal ! Tu commences à avoir de vrais réflexes !",
        "Record battu ! Tu deviens forts... pour les débutants.",
        "Bravo ! Tu quittes officiellement la catégorie 'catastrophique' !",
        "Nouveau record ! le FC YouTube te remercie pour ton assiduité !",
        "Impressionnant ! Tu reconnais plus de vidéos que de visages !"
    ]
    
    private static let messages6to8 = [
        "Ok là ça devient sérieux ! T'as une playlist 'À regarder plus tard' de 500 vidéos ?",
        "Record personnel ! Tu passes trop de temps sur YouTube, mais ça paye !",
        "Pas mal ! Tu dois avoir YouTube en page d'accueil non ?",
        "Bravo ! Tu es officiellement accro aux vidéos !",
        "Nouveau record ! Tes suggestions YouTube doivent être... intéressantes."
    ]
    
    private static let messages9to12 = [
        "Double chiffres ! Tu fais maintenant partie de l'élite !",
        "Record battu ! YouTube Premium, c'est toi ?",
        "Incroyable ! Tu dois avoir des onglets YouTube partout !",
        "Hall of Fame, nous voilà !"
    ]
    
    private static let messages13to15 = [
        "Ok là c'est louche... Tu bosses chez YouTube ?",
        "Record stratosphérique ! T'as mémorisé les tendances ?",
        "Nouveau record ! L'algorithme YouTube, c'est toi qui l'as codé ?",
        "Suspect... On va vérifier tes historiques !"
    ]
    
    private static let messages16to18 = [
        "Attends... tu triches c'est pas possible autrement !",
        "Record inhumain ! Tu as un implant YouTube dans le cerveau ?",
        "VAR ! On demande la VAR ! Y'a triche !",
        "C'est louche... Tu regardes YouTube en x2 pour voir plus de vidéos ?",
        "Nouveau record ! Mais avoue, t'as ouvert YouTube dans un autre onglet !",
    ]
    
    private static let messages19to20 = [
        "Record légendaire ! Tu ES YouTube à ce stade !",
        "Impossible sans triche ! On veut voir tes logs de navigation !",
        "Tu vis dans les serveurs YouTube ou quoi ?",
    ]
    
    private static let messages21to25 = [
        "Ok champion, maintenant avoue ton secret !",
        "Record mythique ! L'algo YouTube travaille pour toi !",
        "Tu dois rêver en miniatures YouTube la nuit...",
    ]
    
    private static let messages26to30 = [
        "Record divin !",
        "Il va falloir qu'on parle sérieusement de tes habitudes de visionnage...",
        "Il est temps de sortir de chez toi et de voir le soleil !",
    ]
    
    private static let messages30plus = [
        "IMPOSSIBLE ! C'est quelle sorcellerie ça ?",
        "WTF ! Meme nous (les créateurs) ont a jamais fait ça!",
        "Tu dois avoir un pacte avec le diable pour ça !",
        "On va devoir t'envoyer un détective pour vérifier ça !",
        "C'est pas humain ça ! T'es un robot ou quoi ?",
        "Il faut vous arrêter là, c'est dangereux pour la santé mentale !",
        "On va devoir t'interdire l'accès à YouTube pour ta propre sécurité !",
        "Tu devrais consulter un spécialiste des addictions aux écrans !",
        
    ]
}
